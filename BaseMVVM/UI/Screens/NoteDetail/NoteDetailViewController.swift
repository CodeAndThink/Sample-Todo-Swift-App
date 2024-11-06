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
    @IBOutlet weak var taskTitleText: UITextField!
    @IBOutlet weak var timeTitleText: UITextField!
    @IBOutlet weak var dateTitleText: UITextField!
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var noteCateButton: UIButton!
    @IBOutlet weak var celeCateButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var calendarCateButton: UIButton!
    
    let datePickerButton = UIButton(type: .custom)
    let timePickerButton = UIButton(type: .custom)
    let datePickerAlertController = UIAlertController(title: "Select date", message: nil, preferredStyle: .actionSheet)
    let timePickerAlertController = UIAlertController(title: "Select time", message: nil, preferredStyle: .actionSheet)
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    private var cateSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        
        setUpAppBar()
        
        setUpDateTimePicker()
        
        setUpAlertController()
        
        setTextHolderTextView()
    }
    
    func setUpAppBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setUpDateTimePicker () {
        datePickerButton.setImage(UIImage(named: "ic_datepicker"), for: .normal)
        datePickerButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let datePickerButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        datePickerButtonContainer.addSubview(datePickerButton)
        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        datePickerButton.layer.cornerRadius = 50
        datePickerButton.backgroundColor = UIColor.white
        datePickerButton.tintColor = UIColor.black
        
        timePickerButton.setImage(UIImage(named: "ic_timepicker"), for: .normal)
        timePickerButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let timePickerButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        timePickerButtonContainer.addSubview(timePickerButton)
        timePickerButton.addTarget(self, action: #selector(showTimePicker), for: .touchUpInside)
        timePickerButton.layer.cornerRadius = 50
        timePickerButton.backgroundColor = UIColor.white
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
    
    func setUpAlertController () {
        timePickerAlertController.view.addSubview(timePicker)
        timePicker.isHidden = false
        
        datePickerAlertController.view.addSubview(datePicker)
        datePicker.isHidden = false
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: datePickerAlertController.view.centerXAnchor),
            datePickerAlertController.view.heightAnchor.constraint(equalToConstant: 500),
            datePicker.bottomAnchor.constraint(equalTo: datePickerAlertController.view.centerYAnchor, constant: 120),
            
            timePicker.centerXAnchor.constraint(equalTo: timePickerAlertController.view.centerXAnchor),
            timePickerAlertController.view.heightAnchor.constraint(equalToConstant: 400),
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
    
    @objc func showDatePicker() {
        present(datePickerAlertController, animated: true, completion: nil)
    }
    
    @objc func showTimePicker() {
        present(timePickerAlertController, animated: true, completion: nil)
    }
    
    @objc func timeChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = Configs.DateFormart.time
        timeTitleText.text = formatter.string(from: timePicker.date)
    }
    
    @objc func dateChanged() {
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
            createNewNote()
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
        let newNote: Note = Note(id: nil, device_id: nil, task_title: taskTitleText.text!, category: cateSelected, content: noteText.text, status: false, date: dateTitleText.text!, time: timeTitleText.text ?? nil)
        return newNote
    }
}

extension NoteDetailViewController : UITextViewDelegate {
    private func setTextHolderTextView(){
            noteText.delegate = self
            noteText.text = "Notes"
            noteText.textColor = UIColor.gray
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
                textView.textColor = UIColor.gray
            }
        }
}
