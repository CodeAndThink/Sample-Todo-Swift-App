//
//  SectionOfItems.swift
//  BaseMVVM
//
//  Created by admin on 11/11/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfItems {
    var header: String
    var items: [Item]
}

extension SectionOfItems: SectionModelType {
    typealias Item = ToDoCellViewModel
    
    init(original: SectionOfItems, items: [Item]) {
        self = original
        self.items = items
    }
}
