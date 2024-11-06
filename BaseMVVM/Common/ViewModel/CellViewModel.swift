//
//  CellViewModel.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 1/4/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CellViewModel{
    var disposeBag = DisposeBag()
    let title = BehaviorRelay<String?>(value: nil)
    let category = BehaviorRelay<Int?>(value: nil)
    let date = BehaviorRelay<String?>(value: nil)
    let time = BehaviorRelay<String?>(value: nil)
    let content = BehaviorRelay<String?>(value: nil)
    var status = BehaviorRelay<Bool?>(value: nil)
}
