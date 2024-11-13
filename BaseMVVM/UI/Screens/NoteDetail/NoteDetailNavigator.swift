//
//  NoteDetailNavigator.swift
//  BaseMVVM
//
//  Created by admin on 29/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//
import Foundation
import QuartzCore

class NoteDetailNavigator : Navigator{
    func pushHome(){
        let viewController = HomeViewController(nibName: HomeViewController.className, bundle: nil)
        let navigator = HomeNavigator(with: viewController)
        let viewModel = HomeViewModel(navigator: navigator)
        viewController.viewModel = viewModel
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] () in
            guard let self = self else { return }
            if let count = self.navigationController?.viewControllers.count, count >= 2 {
                self.navigationController?.viewControllers.removeSubrange(0..<count - 1 )
            }
        }
        navigationController?.popViewController(animated: true)
        CATransaction.commit()
    }
}
