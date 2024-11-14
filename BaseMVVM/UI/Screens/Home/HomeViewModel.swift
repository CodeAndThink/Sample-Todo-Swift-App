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
    
    func handleViewDetail(note: Note) {
        navigator.pushDetail(data: note)
    }
    
    func handleItemTapped(cellVM: ToDoCellViewModel) {
        navigator.pushDetail(data: cellVM.note)
    }
    
    func reloadData() {
        fetchNotes()
    }
    
    func updateData(index : Int, type : Int) {
        if type == 0 {
            self.updateNoteStatus(currentNote: self.todoCellVMs.value[index].note)
        } else{
            self.updateNoteStatus(currentNote: self.doneCellVMs.value[index].note)
        }
    }
    
    func deleteData(index : Int, type : Int) {
        if type == 0 {
            deleteNote(noteId: self.todoCellVMs.value[index].note.id!)
        } else{
            deleteNote(noteId: self.doneCellVMs.value[index].note.id!)
        }
    }
    
    func logout() {
        AuthManager.shared.token = nil
        UserManager.shared.removeUser()
        Application.shared.presentInitialScreen(in: appDelegate.window)
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
                    DispatchQueue.main.async {
                        self?.navigator.showAlert(title: "Common.Error".translated(),
                                                  message: error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func updateNoteStatus(currentNote: Note) {
        Application.shared.apiProvider
            .updateNoteStatus(noteId: currentNote.id!, status: !currentNote.status)
            .subscribe(
                onSuccess: { status in
                    let newNotes = self.notes.value.map { note -> Note in
                    let mutableNote = note
                    if note.id == currentNote.id {
                        mutableNote.status = !mutableNote.status
                    }
                    return mutableNote
                }
                self.notes.accept(newNotes)
                },
                onError: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.navigator.showAlert(title: "Common.Error".translated(),
                                                  message: error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func deleteNote(noteId : Int) {
        Application.shared.apiProvider.deleteNote(noteId: noteId)
            .subscribe(
                onSuccess: { _ in
                    let newNotes = self.notes.value.filter { note in
                        return note.id != noteId
                    }
                
                    self.notes.accept(newNotes)
                },
                onError: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.navigator.showAlert(title: "Common.Error".translated(),
                                                  message: error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
