//
//  NoteDetailViewModel.swift
//  BaseMVVM
//
//  Created by admin on 29/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//

import Foundation

class NoteDetailViewModel : ViewModel {
    // MARK: Public Properties
    let note : Note?
    
    // MARK: Private Properties
    private let navigator: NoteDetailNavigator
    
    init(navigator: NoteDetailNavigator, note : Note?) {
        self.navigator = navigator
        self.note = note
        super.init(navigator: navigator)
    }
    
    // MARK: Public Function
    
    func handleCloseButtonTap(){
        DispatchQueue.main.async {
            self.navigator.pushHome()
        }
    }
    
    func createNewNote(newNote : Note){
        Application.shared.apiProvider
            .createNote(newNote: newNote)
            .trackActivity(ActivityIndicator())
            .subscribe(
                onNext: { message in
                    DispatchQueue.main.async {
                        self.navigator.pushHome()
                    }
                },
                onError: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.navigator.showAlert(title: "Error",
                                                  message: error.localizedDescription)
                    }
                    
                }
            )
            .disposed(by: disposeBag)    }
    
    func updateCurrentNote(oldNote : Note) {
        Application.shared.apiProvider
            .updateNote(newNote: oldNote)
            .trackActivity(ActivityIndicator())
            .subscribe(
                onNext: { message in
                    
                    DispatchQueue.main.async {
                        self.navigator.pushHome()
                        self.navigator.showAlert(title: "Success",
                                                  message: "Update success!")
                    }
                },
                onError: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.navigator.showAlert(title: "Error",
                                                  message: error.localizedDescription)
                    }
                    
                }
            )
            .disposed(by: disposeBag)
//        self.navigator.showAlert(title: "From Dev", message: "Upcomming!")
    }
    
    // MARK: Private Function
}
