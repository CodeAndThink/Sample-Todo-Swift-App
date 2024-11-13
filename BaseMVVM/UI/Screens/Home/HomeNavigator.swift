//
//  HomeNavigator.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/21/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import QuartzCore

class HomeNavigator: Navigator {
    func pushAddNewTask() {
        let viewController = NoteDetailViewController(nibName: NoteDetailViewController.className, bundle: nil)
        let navigator = NoteDetailNavigator(with: viewController)
        let viewModel = NoteDetailViewModel(navigator: navigator, note: nil)
        viewController.viewModel = viewModel
        CATransaction.begin()
        navigationController?.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
    func pushDetail(data: Note) {
        let viewController = NoteDetailViewController(nibName: NoteDetailViewController.className, bundle: nil)
        let navigator = NoteDetailNavigator(with: viewController)
        let viewModel = NoteDetailViewModel(navigator: navigator, note: data)
        viewController.viewModel = viewModel
        CATransaction.begin()
        navigationController?.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}
