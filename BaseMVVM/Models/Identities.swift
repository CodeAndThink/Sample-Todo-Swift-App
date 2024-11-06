//
//  Identities.swift
//  BaseMVVM
//
//  Created by admin on 5/11/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//
import Foundation
import ObjectMapper

class Identity: Decodable, Mappable {
    var id: String?            // ID của phương thức xác thực
    var userId: String?        // ID của người dùng
    var provider: String?      // Nhà cung cấp (ví dụ: google, facebook)
    var providerId: String?    // ID của người dùng từ nhà cung cấp
    var createdAt: String?     // Thời điểm phương thức này được liên kết
    var lastSignInAt: String?  // Thời điểm đăng nhập gần nhất với phương thức này
    var updatedAt: String?     // Thời điểm cập nhật gần nhất

    required init?(map: Map) {
        // Khởi tạo đối tượng từ JSON
    }
    
    func mapping(map: Map) {
        id            <- map["id"]
        userId        <- map["user_id"]
        provider      <- map["provider"]
        providerId    <- map["provider_id"]
        createdAt     <- map["created_at"]
        lastSignInAt  <- map["last_sign_in_at"]
        updatedAt     <- map["updated_at"]
    }
}
