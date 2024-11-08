//
//  ToDoViewCell.swift
//  BaseMVVM
//
//  Created by admin on 29/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
class ToDoTableViewCell : TableViewCell {
    
    @IBOutlet private weak var cateIconImage: UIImageView!
    @IBOutlet private weak var taskTitleLabel: UILabel!
    @IBOutlet private weak var dateTimeLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!

    private let listCateIcon : [String] = ["ic_note_white", "ic_calendal_white", "ic_archive_white"]
    private let listIconColor : [String] = ["cateColor1", "cateColor2", "cateColor3"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func bind(viewModel: CellViewModel) {
        guard let viewModel = viewModel as? ToDoCellViewModel else {
            return
        }
        viewModel.title.bind(to: taskTitleLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.category
            .map { UIImage(named: self.listCateIcon[$0 ?? 0] ) }
            .bind(to: (cateIconImage.rx.image))
            .disposed(by: disposeBag)
        
        viewModel.category
            .map { index in
                UIColor(named: self.listIconColor[index ?? 0]) ?? .clear
            }
            .bind(to: (cateIconImage.rx.backgroundColor))
            .disposed(by: disposeBag)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "hh:mm a"

        viewModel.time
            .map { timeString -> String? in
                guard let date = dateFormatter.date(from: timeString ?? "") else {
                    return nil
                }
                return displayFormatter.string(from: date)
            }
            .bind(to: dateTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.status
            .map { !($0 ?? true) ? UIImage(named: "ic_checkbox_off") : UIImage(named: "ic_checkbox_on") }
            .bind(to: checkBoxButton.rx.backgroundImage(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.status
            .map { status -> NSAttributedString? in
                let text = self.taskTitleLabel.text
                if status == true {
                    return NSAttributedString(string: text ?? "", attributes: [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue
                    ])
                } else {
                    return NSAttributedString(string: text ?? "", attributes: [
                        .strikethroughStyle: 0
                    ])
                }}
            .bind(to: taskTitleLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.status
            .map { status -> NSAttributedString? in
                let text = self.dateTimeLabel.text
                if status == true {
                    return NSAttributedString(string: text ?? "", attributes: [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue
                    ])
                } else {
                    return NSAttributedString(string: text ?? "", attributes: [
                        .strikethroughStyle: 0
                    ])
                }}
            .bind(to: dateTimeLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        checkBoxButton.rx.tap.bind { _ in
            viewModel.handleCheckButtonAction()
        }.disposed(by: disposeBag)
    }
}
