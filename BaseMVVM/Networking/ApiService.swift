//
//  AppAPI.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/25/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire

enum ApiService {
    // MARK: - Authentication
    case login(username: String, password: String)
    case register(username: String, password: String)
    // MARK: - Profile
    case getProfile
    // MARK: - CRUD Data
    case createNote(newNote : Note)
    case fetchNotesForUser
    case deleteNote(noteId : Int)
    case updateNote(noteId: Int, status: Bool)
}
