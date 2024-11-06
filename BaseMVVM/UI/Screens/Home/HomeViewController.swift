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

class HomeViewController: ViewController<HomeViewModel, HomeNavigator> {
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var addNewTaskButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var ToDoTableView: UITableView!
    @IBOutlet weak var DoneTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadData()
        viewModel.listenDataChange()
    }

    override func setupUI() {
        super.setupUI()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        currentDateLabel.text = updateCurrentDate()
        
        ToDoTableView.register(nibWithCellClass: ToDoTableViewCell.self)
        
        DoneTableView.register(nibWithCellClass: ToDoTableViewCell.self)
    }
    
    private func updateCurrentDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    override func setupListener() {
        super.setupListener()
        
        setUpListenerToDoTable()
        setUpListenerDoneTable()
        
        viewModel.loadingIndicator.asObservable().bind(to: isLoading).disposed(by: disposeBag)
        
        addNewTaskButton.rx.tap.bind { [weak self] () in
            self?.viewModel.handleAddNewTaskButtonTap()
        }.disposed(by: disposeBag)
        
        signoutButton.rx.tap.bind {[weak self] () in
            self?.viewModel.logout()
        }.disposed(by: disposeBag)
    }
    
    private func setUpListenerToDoTable(){
        ToDoTableView.rx.prefetchRows.subscribe(onNext: {[weak self] indexPaths in
            guard let self = self else { return }
            let count = self.viewModel.todoCellVMs.value.count
            if indexPaths.contains(where: { (indexPath) -> Bool in
                return count == indexPath.row + 1
            }) {
                viewModel.reloadData()
            }
        }).disposed(by: disposeBag)
        
        viewModel.todoCellVMs.asDriver(onErrorJustReturn: [])
            .drive(self.ToDoTableView.rx.items(cellIdentifier: ToDoTableViewCell.className, cellType: ToDoTableViewCell.self)) { tableView, viewModel, cell in
                cell.bind(viewModel: viewModel)
            }.disposed(by: self.disposeBag)
        
        ToDoTableView.rx.modelSelected(ToDoCellViewModel.self).bind { [weak self] cellVM in
            guard let self = self else { return }
            self.viewModel.handleItemTapped(cellVM: cellVM)
        }.disposed(by: disposeBag)
    }
    
    private func setUpListenerDoneTable(){
        DoneTableView.rx.prefetchRows.subscribe(onNext: {[weak self] indexPaths in
            guard let self = self else { return }
            let count = self.viewModel.doneCellVMs.value.count
            if indexPaths.contains(where: { (indexPath) -> Bool in
                return count == indexPath.row + 1
            }) {
                viewModel.reloadData()
            }
        }).disposed(by: disposeBag)
        
        viewModel.doneCellVMs.asDriver(onErrorJustReturn: [])
            .drive(self.DoneTableView.rx.items(cellIdentifier: ToDoTableViewCell.className, cellType: ToDoTableViewCell.self)) { tableView, viewModel, cell in
                cell.bind(viewModel: viewModel)
            }.disposed(by: self.disposeBag)
        
        DoneTableView.rx.modelSelected(ToDoCellViewModel.self).bind { [weak self] cellVM in
            guard let self = self else { return }
            self.viewModel.handleItemTapped(cellVM: cellVM)
        }.disposed(by: disposeBag)
    }
}
