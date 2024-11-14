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
    @IBOutlet private weak var ToDoTableView: UITableView!
    @IBOutlet private weak var homeTitle: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ToDoTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func setupUI() {
        super.setupUI()
        
        languageChanged()
        
        ToDoTableView.register(nibWithCellClass: ToDoTableViewCell.self)
        ToDoTableView.sectionHeaderTopPadding = 0
        ToDoTableView.sectionHeaderHeight = 67
        
        menuButton.menu = createMenu()
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    private func createMenu() -> UIMenu {
        let action1 = UIAction(title: "Home.MenuButton.Logout".translated(), image: UIImage(named: "ic_logout"), handler: { _ in
            self.viewModel.logout()
        })
        let action2 = UIAction(title: "Home.MenuButton.Language".translated(), image: UIImage(named: "ic_lang"), handler: { [self] _ in
            self.changeLanguageAction()
        })
        return UIMenu(title: "Home.MenuButton.Title".translated(), children: [action1, action2])
    }
    
    private func changeLanguageAction () {
        if LocalizeDefaultLanguage == "en" {
            LocalizeDefaultLanguage = "vi"
        } else {
            LocalizeDefaultLanguage = "en"
        }
        
        UserDefaults.standard.set(LocalizeDefaultLanguage, forKey: LocalizeUserDefaultKey)
        UserDefaults.standard.synchronize()
        
        languageChanged()
        
        viewWillAppear(true)
    }
    
    @objc func languageChanged() {
        currentDateLabel.text = updateCurrentDate()
        homeTitle.text = "Home.Title".translated()
        addNewTaskButton.setTitle("Home.NewTaskButtonTitle".translated(), for: .normal)
        menuButton.menu = createMenu()
    }
    
    override func setupListener() {
        super.setupListener()
        
        setUpListenerToDoTable()
        
        viewModel.loadingIndicator.asObservable().bind(to: isLoading).disposed(by: disposeBag)
        
        addNewTaskButton.rx.tap.bind { [weak self] () in
            self?.viewModel.handleAddNewTaskButtonTap()
        }.disposed(by: disposeBag)
    }
    
    private func updateCurrentDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: LocalizeDefaultLanguage)
        return dateFormatter.string(from: currentDate).localizedCapitalized
    }
    
    private func setUpListenerToDoTable(){
        ToDoTableView.rx.prefetchRows.subscribe(onNext: {[weak self] indexPaths in
            guard let self = self else { return }
            let count = self.viewModel.todoCellVMs.value.count
            if indexPaths.contains(where: { (indexPath) -> Bool in
                return count == indexPath.row + 3
            }) {
                viewModel.reloadData()
            }
        }).disposed(by: disposeBag)
        
        let sections = Observable.combineLatest(viewModel.todoCellVMs, viewModel.doneCellVMs) { todoItems, doneItems in
            return [
                SectionOfItems(header: "", items: todoItems),
                SectionOfItems(header: "Home.SectionTitle".translated(), items: doneItems)
            ]
        }
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfItems>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withClass: ToDoTableViewCell.self, for: indexPath)
                cell.bind(viewModel: item)
                cell.checkBoxButton.rx.tap.bind {
                    cell.alpha = 1
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.alpha = 0
                        cell.transform = CGAffineTransform(scaleX: 1, y: 0.5)
                    }, completion: { _ in
                        self.viewModel.updateData(index: indexPath[1], type: indexPath[0])
                        
                        cell.transform = .identity
                    })
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
    }
}

extension HomeViewController : UITableViewDelegate {
    
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
        
        if isLoaded == false {
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.bounds.size.height)
            UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut, animations: {
                cell.transform = .identity
            }, completion: { _ in
                self.isLoaded = true
            })
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
                guard let self = self else { return }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.alpha = 1
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.alpha = 0
                    }, completion: { _ in
                        self.viewModel.deleteData(index: indexPath[1], type: indexPath[0])
                    })
                }
                completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
