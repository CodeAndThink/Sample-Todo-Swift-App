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
    
    func handleSaveButton(taskTitle: String, category: Int, content: String, date: String, time: String, isCreate : Bool) {
        if taskTitle.isEmpty == true {
            DispatchQueue.main.async {
                self.navigator.showAlert(title: "Error", message: "Please enter task title!")
            }
        }
        else if date.isEmpty == true {
            DispatchQueue.main.async {
                self.navigator.showAlert(title: "Error", message: "Please enter date!")
            }
        } else {
            let time: String? = time.isEmpty == true ? nil : time
            let content : String? = content == "Notes".translated() ? nil : content
            let noteId : Int? = self.note == nil ? nil : self.note?.id
            let status : Bool = self.note == nil ? false : self.note!.status
            let newNote: Note = Note(id: noteId, device_id: nil, task_title: taskTitle, category: category, content: content, status: status, date: date, time: time)
            
            if isCreate {
                createNewNote(newNote: newNote)
            } else {
                updateCurrentNote(oldNote: newNote)
            }
        }
    }
    
    private func createNewNote(newNote : Note){
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
    
    private func updateCurrentNote(oldNote : Note) {
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
    }
    
    // MARK: Private Function
}
