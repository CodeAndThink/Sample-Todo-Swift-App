//
//  HomeViewController.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/21/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import UIKit
import SnapKit
import RxRelay
import MBProgressHUD
import RxCocoa
import RxSwift
import RxDataSources

class HomeViewController: ViewController<HomeViewModel, HomeNavigator> {
    @IBOutlet private weak var currentDateLabel: UILabel!
    @IBOutlet private weak var addNewTaskButton: UIButton!
    @IBOutlet private weak var signoutButton: UIButton!
    @IBOutlet private weak var ToDoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadData()
    }
    
    override func setupUI() {
        super.setupUI()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        currentDateLabel.text = updateCurrentDate()
        
        ToDoTableView.register(nibWithCellClass: ToDoTableViewCell.self)
        ToDoTableView.sectionHeaderTopPadding = 0
        ToDoTableView.sectionHeaderHeight = 67
    }
    
    override func setupListener() {
        super.setupListener()
        
        setUpListenerToDoTable()
        
        viewModel.loadingIndicator.asObservable().bind(to: isLoading).disposed(by: disposeBag)
        
        addNewTaskButton.rx.tap.bind { [weak self] () in
            self?.viewModel.handleAddNewTaskButtonTap()
        }.disposed(by: disposeBag)
        
        signoutButton.rx.tap.bind {[weak self] () in
            self?.viewModel.logout()
        }.disposed(by: disposeBag)
    }
    
    private func updateCurrentDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    private func setUpListenerToDoTable(){
        ToDoTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        ToDoTableView.rx.prefetchRows.subscribe(onNext: {[weak self] indexPaths in
            guard let self = self else { return }
            let count = self.viewModel.todoCellVMs.value.count
            if indexPaths.contains(where: { (indexPath) -> Bool in
                return count == indexPath.row + 1
            }) {
                viewModel.reloadData()
            }
        }).disposed(by: disposeBag)
        
        let sections = Observable.combineLatest(viewModel.todoCellVMs, viewModel.doneCellVMs) { todoItems, doneItems in
            return [
                SectionOfItems(header: "", items: todoItems),
                SectionOfItems(header: "Completed", items: doneItems)
            ]
        }
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfItems>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withClass: ToDoTableViewCell.self, for: indexPath)
                cell.bind(viewModel: item)
                cell.checkBoxButton.rx.tap.bind {
                    self.viewModel.updateData(index: indexPath[1], type: indexPath[0])
                }.disposed(by: cell.disposeBag)
                
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
        
        sections
            .bind(to: ToDoTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        ToDoTableView.rx.modelSelected(ToDoCellViewModel.self).bind { [weak self] cellVM in
            guard let self = self else { return }
            
            self.viewModel.handleViewDetail(note: cellVM.note)
        }.disposed(by: disposeBag)
        
        ToDoTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.deleteData(index: indexPath[1], type: indexPath[0])
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            setAllCorner()
        } else {
            if indexPath.row == 0 {
                setTopCorners()
            } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                setBottomCorners()
            } else {
                setDefaultCorners()
            }
        }
        
        func setTopCorners() {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
        }
        
        func setBottomCorners() {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
        }
        
        func setDefaultCorners() {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft],
                                        cornerRadii: CGSize(width: 0, height: 0))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
        }
        
        func setAllCorner() {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft],
                                        cornerRadii: CGSize(width: 10, height: 10))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor(named: "textColor")
    }
}

