//
//  SignUpViewModel.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/20/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SignUpViewModel: ViewModel {
    // MARK: Public Properties
    
    // MARK: Private Properties
    private let navigator: SignUpNavigator
    
    private let userName = BehaviorRelay(value: "")
    private let password = BehaviorRelay(value: "")
    
    init(navigator: SignUpNavigator) {
        self.navigator = navigator
        super.init(navigator: navigator)
    }
    
    // MARK: Public Function
    
    func changeUserName(userName: String) -> Void {
        self.userName.accept(userName)
    }
    
    func changePassword(password: String) -> Void {
        self.password.accept(password)
    }
    
    func signUp() {
        let userName = self.userName.value
        if userName.isEmpty {
            navigator.showAlert(title: "Common.Error".translated(),
                                message: "Login.Username.Empty".translated())
            return
        }
        let password = self.password.value
        if password.isEmpty {
            navigator.showAlert(title: "Common.Error".translated(),
                                message: "Login.Password.Empty".translated())
            return
        }
        
        Application.shared
            .mockProvider
            .register(deviceId: userName, password: password)
            .trackActivity(loadingIndicator)
            .subscribe(onNext: { [weak self] token in
                guard self != nil else { return }
                DispatchQueue.main.async {
                    self?.navigator.pushSignIn()
                }
            }, onError: {[weak self] error in
                DispatchQueue.main.async {
                    self?.navigator.showAlert(title: "Common.Error".translated(),
                                              message: "Login.Username.Password.Invalid".translated())
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: Private Function
}
