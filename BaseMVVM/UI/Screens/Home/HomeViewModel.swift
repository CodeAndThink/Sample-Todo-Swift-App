//
//  HomeViewModel.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/21/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel: ViewModel {
    // MARK: Public Properties
    let todoCellVMs = BehaviorRelay<[ToDoCellViewModel]>(value: [])
    let doneCellVMs = BehaviorRelay<[ToDoCellViewModel]>(value: [])
    
    // MARK: Private Properties
    private let navigator: HomeNavigator
    private let notes = BehaviorRelay<[Note]>(value: [])
    
    init(navigator: HomeNavigator) {
        self.navigator = navigator
        super.init(navigator: navigator)
        // Setup listener
        
        notes.map { notes -> [ToDoCellViewModel] in
            return notes
                .filter { $0.status == false }
                .map { note -> ToDoCellViewModel in
                    return ToDoCellViewModel(note: note)
                }
        }.bind(to: todoCellVMs).disposed(by: disposeBag)
        
        notes.map { notes -> [ToDoCellViewModel] in
            return notes
                .filter { $0.status == true }
                .map { note -> ToDoCellViewModel in
                    return ToDoCellViewModel(note: note)
                }
        }.bind(to: doneCellVMs).disposed(by: disposeBag)
    }
    
    // MARK: Public Function
    
    func handleAddNewTaskButtonTap(){
        navigator.pushAddNewTask()
    }
    
    func handleItemTapped(cellVM: ToDoCellViewModel) {
        navigator.pushDetail(data: cellVM.note)
    }
    
    func reloadData() {
        fetchNotes()
    }
    
    func logout() {
        AuthManager.shared.token = nil
        UserManager.shared.removeUser()
        Application.shared.presentInitialScreen(in: appDelegate.window)
    }
    
    func listenDataChange() {
        Application.shared.apiProvider.dataUpdateListener()
            .subscribe(
                onNext: { newNote in
                    let updatedNotes = self.notes.value.map { note -> Note in
                        let mutableNote = note
                        if note.id == newNote.id {
                            mutableNote.status = newNote.status
                        }
                        return mutableNote
                    }
                    self.notes.accept(updatedNotes)
                },
                onError: { [weak self] error in
                    self?.navigator.showAlert(title: "UpdateError",
                                              message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: Private Function
    
    private func fetchNotes() {
        Application.shared.apiProvider.fetchNotesForUser()
            .trackActivity(loadingIndicator)
            .subscribe(
                onNext: { notesData in
                    self.notes.accept(notesData)
                },
                onError: { [weak self] error in
                    self?.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
