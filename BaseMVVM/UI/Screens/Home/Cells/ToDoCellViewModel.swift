//
//  ToDoCellViewModel.swift
//  BaseMVVM
//
//  Created by admin on 29/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//

import Foundation
import RxRelay

class ToDoCellViewModel : CellViewModel {
    let note : Note
    let onDoneTapped = PublishRelay<Note>()
    
    init(note: Note) {
        self.note = note
        super.init()
        self.title.accept(note.task_title)
        self.category.accept(note.category)
        self.date.accept(note.date)
        self.time.accept(note.time)
        self.content.accept(note.content)
        self.status.accept(note.status)
    }
    
    // MARK: Public Functions
    
    func handleCheckButtonAction() {
        onDoneTapped.accept(note)
    }
}
