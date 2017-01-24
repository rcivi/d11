//
//  AddOrEditController.swift
//  D11
//
//  Created by Ruggero Civitarese on 18/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate


class AddOrEditController: UITableViewController {

	@IBOutlet var addOrEditTable: UITableView!
	@IBOutlet weak var addOrSaveButton: UIBarButtonItem!
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var navigationBar: UINavigationItem!

	//MARK: - TABLE ELEMENTS

	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var allDaySwitch: UISwitch!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var timePicker: UIDatePicker!

	//MARK: -

	var addOrEditEvent: Event?
	var datePickerIsVisible: Bool = false
	var timePickerIsVisible: Bool = false
	var theResult: Result?



	//MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()

		//		 Removes empty lines in the table
		addOrEditTable.tableFooterView = UIView()

		// To dismiss keyboard after a tap outside
//		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
//		self.view.addGestureRecognizer(tapGesture)

		setupAddTargetIsNotEmptyTextFields()

		var tempDate: Date?

		if let ev = addOrEditEvent {

			// EDIT EXISTING EVENT

			navigationBar.title = "Edit Event"
			addOrSaveButton.isEnabled = true

			titleTextField.text = ev.title!
			allDaySwitch.setOn(ev.allday, animated: true)

			if allDaySwitch.isOn { datePicker.datePickerMode = .date } else { datePicker.datePickerMode = .dateAndTime }

			tempDate = ev.date as Date?

		} else {

			// ADDING A NEW EVENT

			print("No event arrived here from AddOrEditController.")
			navigationBar.title = "New Event"
			addOrSaveButton.isEnabled = false

			titleTextField.text = ""
			allDaySwitch.setOn(true, animated: true)
			datePicker.datePickerMode = .date

			tempDate = Date()
		}

		displayDate(date: tempDate!)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch(section) {
		case 0:
			return 1
		case 1:
			return 3
		case 2:
			return 1
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if indexPath.section == 1 && indexPath.row == 1 {
			datePickerIsVisible = !datePickerIsVisible
			tableView.beginUpdates()
			addOrEditTable.reloadData()
			if datePickerIsVisible { dateLabel.textColor = UIColor.red } else { dateLabel.textColor = UIColor.black }
			tableView.endUpdates()
		}
	}


	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		var heigth: CGFloat = 0.0

		if indexPath.section == 1 && indexPath.row == 2 {
			if datePickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else {
			heigth = 44.0
		}
		return heigth
	}


	func displayDate(date: Date) {

		if allDaySwitch.isOn {
			// DISPLAY DATE AND TIME
			dateLabel.text = dateOnlyFormatter.string(from: date)
			datePicker.datePickerMode = .date
		} else {
			// DISPLAY DATE ONLY
			dateLabel.text = dateAndTimeFormatter.string(from: date)
			datePicker.datePickerMode = .dateAndTime
		}
		datePicker.setDate(date, animated: true)
	}


	@IBAction func allDaySwitchClicked(_ sender: Any) {

		var result = ""
		guard let dateString = dateLabel.text else { return }

		if allDaySwitch.isOn {
			if let date = dateAndTimeFormatter.date(from: dateString) {
				result = dateOnlyFormatter.string(from: date)
				datePicker.datePickerMode = .date
			}
		} else {
			if let date = dateOnlyFormatter.date(from: dateString) {
				result = dateAndTimeFormatter.string(from: date)
				datePicker.datePickerMode = .dateAndTime
			}
		}

		dateLabel.text = result
	}

	@IBAction func datePickerValueChanged(_ sender: Any) {

		let date = datePicker.date
		displayDate(date: date)
	}


	@IBAction func cancelButtonClicked(_ sender: Any) {
		debugPrint("Cancel button pressed")
	}

	@IBAction func addOrSaveButtonClicked(_ sender: Any) {
		debugPrint("Add or Save button pressed")
	}


	// MARK: - SEGUE Navigation

	    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	
			debugPrint("Preparing to return from AddOrEditController to MainController")

			if sender is UIBarButtonItem {
				debugPrint("Cancel or AddOrSave button pressed")

				let clickedButton = sender as! UIBarButtonItem
				let buttonTag = clickedButton.tag

				var action: ActionToReturn

				if buttonTag == 1 {
					action = ActionToReturn.canceled
				} else {
					if addOrEditEvent != nil {
						action = ActionToReturn.edited
					} else {
						action = ActionToReturn.added
					}
				}
				
				theResult = Result(action: action,
				                   title: titleTextField.text!.trimmingCharacters(in: .whitespaces),
				                   date: dateLabel.text!,
				                   allday: allDaySwitch.isOn,
				                   repeatition: false,
				                   every: Every.never
				)
				debugPrint(theResult!)
			}
	     }
	
	//MARK: - KEYBOARD

	// Chiude la tastiera quando l'utente clicca fuori dalla tastiera
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		debugPrint("-- touchesBegan")
		self.view.endEditing(true)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		titleTextField.resignFirstResponder()
		return true
	}

	func tap(gesture: UITapGestureRecognizer) {
		titleTextField.resignFirstResponder()
	}

	// Enable and Disable AddOrSaveButton if title is empty or not

	func setupAddTargetIsNotEmptyTextFields() {

//		addOrSaveButton.isEnabled = false
		titleTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
	}

	func textFieldsIsNotEmpty(sender: UITextField) {

		if let str = sender.text?.trimmingCharacters(in: .whitespaces) {
			self.addOrSaveButton.isEnabled = !str.isEmpty
		}
	}

}
