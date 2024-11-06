//
//  User.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 1/5/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//
import Foundation
import ObjectMapper

class User: Mappable {
    var id: String = ""            // Mã định danh duy nhất của người dùng
    var email: String?        // Email của người dùng, có thể null nếu dùng phương thức đăng nhập khác
    var phone: String?        // Số điện thoại, nếu có
    var createdAt: String = ""     // Thời điểm tài khoản được tạo
    var confirmedAt: String?  // Thời điểm tài khoản được xác nhận
    var lastSignInAt: String? // Thời điểm đăng nhập gần nhất
    var role: String?         // Vai trò của người dùng, nếu được gán
    var appMetadata: [String: Any]?   // Metadata từ ứng dụng, bao gồm provider đăng nhập
    var userMetadata: [String: Any]?  // Metadata có thể tùy chỉnh cho người dùng
    var identities: [Identity]?       // Danh sách các phương thức đăng nhập khác

    required init?(map: Map) {
        // Khởi tạo đối tượng từ JSON, có thể thêm kiểm tra để xử lý trường hợp JSON không hợp lệ
    }
    init() {}
    
    func mapping(map: Map) {
        id              <- map["id"]
        email           <- map["email"]
        phone           <- map["phone"]
        createdAt       <- map["created_at"]
        confirmedAt     <- map["confirmed_at"]
        lastSignInAt    <- map["last_sign_in_at"]
        role            <- map["role"]
        appMetadata     <- map["app_metadata"]
        userMetadata    <- map["user_metadata"]
        identities      <- map["identities"]
    }
}

