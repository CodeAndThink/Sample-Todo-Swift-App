//
//  Note.swift
//  BaseMVVM
//
//  Created by admin on 31/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//

import Foundation
import ObjectMapper

class Note : Decodable, Encodable {
    var id : Int?
    var device_id: String?
    var task_title : String
    var category : Int
    var content : String
    var status : Bool
    var date : String
    var time : String?
    
    init(id: Int? = nil, device_id: String?, task_title: String, category: Int, content: String, status: Bool, date: String, time: String? = nil) {
        self.id = id
        self.device_id = device_id
        self.task_title = task_title
        self.category = category
        self.content = content
        self.status = status
        self.date = date
        self.time = time
    }
}
