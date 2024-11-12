//
//  NoteDetailViewController.swift
//  BaseMVVM
//
//  Created by admin on 29/10/24.
//  Copyright © 2024 thoson.it. All rights reserved.
//
import Foundation
import UIKit

class NoteDetailViewController : ViewController<NoteDetailViewModel, NoteDetailNavigator> {
    @IBOutlet private weak var taskTitleText: UITextField!
    @IBOutlet private weak var timeTitleText: UITextField!
    @IBOutlet private weak var dateTitleText: UITextField!
    @IBOutlet private weak var noteText: UITextView!
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var noteCateButton: UIButton!
    @IBOutlet private weak var celeCateButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var calendarCateButton: UIButton!
    
    private let datePickerButton = UIButton(type: .custom)
    private let timePickerButton = UIButton(type: .custom)
    private let datePickerAlertController = UIAlertController(title: "Select date", message: nil, preferredStyle: .actionSheet)
    private let timePickerAlertController = UIAlertController(title: "Select time", message: nil, preferredStyle: .actionSheet)
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    private var cateSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        
        setUpAppBar()
        
        setUpNoteContent()
        
        setUpDateTimePicker()
        
        setUpAlertController()
        
        setTextHolderTextView()
        
        setUpData()
        
        noteText.delegate = self
    }
    
    private func setUpNoteContent(){
        
        noteText.text = "Notes"
        noteText.textColor = UIColor.lightGray
    }
    
    private func setUpData(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateStyle = .medium
        taskTitleText.text = viewModel.note?.task_title
        dateTitleText.text = dateFormatter.string(from: dateFormatter.date(from: viewModel.note?.date ?? "") ?? Date())
        timeTitleText.text = viewModel.note?.time
        cateSelected = viewModel.note?.category ?? 0
        noteText.text = viewModel.note?.content
        
        updateButtonAlpha()
    }
    
    private func setUpAppBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setUpDateTimePicker () {
        datePickerButton.setImage(UIImage(named: "ic_datepicker"), for: .normal)
        datePickerButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let datePickerButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        datePickerButtonContainer.addSubview(datePickerButton)
        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        datePickerButton.backgroundColor = UIColor.clear
        datePickerButton.tintColor = UIColor.black
        
        timePickerButton.setImage(UIImage(named: "ic_timepicker"), for: .normal)
        timePickerButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let timePickerButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        timePickerButtonContainer.addSubview(timePickerButton)
        timePickerButton.addTarget(self, action: #selector(showTimePicker), for: .touchUpInside)
        timePickerButton.backgroundColor = UIColor.clear
        timePickerButton.tintColor = UIColor.black
        
        dateTitleText.rightView = datePickerButtonContainer
        dateTitleText.rightViewMode = .always
        
        timeTitleText.rightView = timePickerButtonContainer
        timeTitleText.rightViewMode = .always
        
        datePicker.datePickerMode = .date
        timePicker.datePickerMode = .time
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
            timePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpAlertController () {
        timePickerAlertController.view.addSubview(timePicker)
        timePicker.isHidden = false
        
        datePickerAlertController.view.addSubview(datePicker)
        datePicker.isHidden = false
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: datePickerAlertController.view.centerXAnchor),
            datePickerAlertController.view.heightAnchor.constraint(equalToConstant: 480),
            datePicker.bottomAnchor.constraint(equalTo: datePickerAlertController.view.centerYAnchor, constant: 120),
            
            timePicker.centerXAnchor.constraint(equalTo: timePickerAlertController.view.centerXAnchor),
            timePickerAlertController.view.heightAnchor.constraint(equalToConstant: 380),
            timePicker.bottomAnchor.constraint(equalTo: timePickerAlertController.view.centerYAnchor, constant: 70)
        ])
        
        let dateConfirmAction = UIAlertAction(title: "Confirm", style: .default){ _ in
            self.dateChanged()
        }
        let dateCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        datePickerAlertController.addAction(dateConfirmAction)
        datePickerAlertController.addAction(dateCancelAction)
        
        let timeConfirmAction = UIAlertAction(title: "Confirm", style: .default){ _ in
            self.timeChanged()
        }
        let timeCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        timePickerAlertController.addAction(timeConfirmAction)
        timePickerAlertController.addAction(timeCancelAction)
    }
    
    @objc private func showDatePicker() {
        present(datePickerAlertController, animated: true, completion: nil)
    }
    
    @objc private func showTimePicker() {
        present(timePickerAlertController, animated: true, completion: nil)
    }
    
    @objc private func timeChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = Configs.DateFormart.time
        timeTitleText.text = formatter.string(from: timePicker.date)
    }
    
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateTitleText.text = formatter.string(from: datePicker.date)
    }
    
    override func setupListener() {
        super.setupListener()
        closeButton.rx.tap.bind { [weak self] () in
            self?.viewModel.handleCloseButtonTap()
        }.disposed(by: disposeBag)
        
        saveButton.rx.tap.bind { [weak self] () in
            guard let self = self else { return }
            if viewModel.note != nil {
                viewModel.updateCurrentNote(oldNote: prepareNewNote())
            } else {
                createNewNote()
            }
        }.disposed(by: disposeBag)
        
        noteCateButton.rx.tap.bind {[weak self] () in
            self?.cateSelected = 0
            self?.updateButtonAlpha()
        }.disposed(by: disposeBag)
        
        calendarCateButton.rx.tap.bind {[weak self] () in
            self?.cateSelected = 1
            self?.updateButtonAlpha()
        }.disposed(by: disposeBag)
        
        celeCateButton.rx.tap.bind {[weak self] () in
            self?.cateSelected = 2
            self?.updateButtonAlpha()
        }.disposed(by: disposeBag)
    }
    
    private func updateButtonAlpha () {
        switch self.cateSelected {
        case 0:
            noteCateButton.alpha = 1
            calendarCateButton.alpha = 0.2
            celeCateButton.alpha = 0.2
        case 1:
            noteCateButton.alpha = 0.2
            calendarCateButton.alpha = 1
            celeCateButton.alpha = 0.2
        case 2:
            noteCateButton.alpha = 0.2
            calendarCateButton.alpha = 0.2
            celeCateButton.alpha = 1
        default:
            noteCateButton.alpha = 1
            calendarCateButton.alpha = 1
            celeCateButton.alpha = 1
        }
    }
    
    private func createNewNote() {
        if taskTitleText.text?.isEmpty == true {
            taskTitleText.attributedPlaceholder = NSAttributedString(
                string: "Please enter task title!",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
            )
        } else if dateTitleText.text?.isEmpty == true {
            dateTitleText.attributedPlaceholder = NSAttributedString(
                string: "Please enter date!",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
            )
        } else {
            let newNote = prepareNewNote()
            self.viewModel.createNewNote(newNote: newNote)
        }
    }
    
    private func prepareNewNote () -> Note {
        let time: String? = timeTitleText.text?.isEmpty == true ? nil : timeTitleText.text
        let content : String? = noteText.text == "Notes" ? nil : noteText.text
        let noteId : Int? = self.viewModel.note?.id == nil ? nil : self.viewModel.note?.id
        let newNote: Note = Note(id: noteId, device_id: nil, task_title: taskTitleText.text!, category: cateSelected, content: content, status: false, date: dateTitleText.text!, time: time)
        return newNote
    }
}

extension NoteDetailViewController : UITextViewDelegate {
    private func setTextHolderTextView(){
        noteText.text = "Notes"
        noteText.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Notes" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGray
        }
    }
}
