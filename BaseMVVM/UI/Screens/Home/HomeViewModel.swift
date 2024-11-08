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
    
    func deleteData(index : Int, tableType : Bool) {
        if tableType {
            deleteNote(noteId: self.doneCellVMs.value[index].note.id!, noteIndex: index)
        } else {
            deleteNote(noteId: self.todoCellVMs.value[index].note.id!, noteIndex: index)
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
                    self?.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func UpdateNoteStatus(currentNote: Note) {
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
                    self?.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func deleteNote(noteId : Int, noteIndex : Int) {
        Application.shared.apiProvider.deleteNote(noteId: noteId)
            .subscribe(
                onSuccess: { _ in
                    var newNotes = self.notes.value
                    newNotes.remove(at: noteIndex)
                    self.notes.accept(newNotes)
                },
                onError: { [weak self] error in
                    self?.navigator.showAlert(title: "Error",
                                              message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
