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


class AddOrEditController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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
	@IBOutlet weak var repeatPicker: UIPickerView!
	@IBOutlet weak var repeatLabel: UILabel!
	@IBOutlet weak var endRepeatPicker: UIPickerView!
	@IBOutlet weak var endRepeatLabel: UILabel!
	@IBOutlet weak var notifyLabel: UILabel!
	@IBOutlet weak var notifyPicker: UIPickerView!


	//MARK: - VARIABLES

	var addOrEditEvent: Event?
	var datePickerIsVisible: Bool = false
	var timePickerIsVisible: Bool = false
	var repeatPickerIsVisible: Bool = false
	var endRepeatPickerIsVisible: Bool = false
	var notifyPickerIsVisible: Bool = false

	var theResult: Result?
	var theDate: Date = Date()
	var theRepeatType: Int = 0
	var theRepeatQuantity: Int = 0
	var theEndRepeatType: Int = 0
	var theEndRepeatQuantity: Int = 0
	var theNotifyType: Int = 0
	var theNotifyQuantity: Int = 0
	var theNotifyMode: Int = 0
	
	let repeats: [String]               = ["never", "minute", "hour", "day", "week", "month", "quarter", "year"]
	let repeatsPlurals: [String]        = ["never", "minutes", "hours", "days", "weeks", "months", "quarters", "years"]
	let endRepatMenu: [String]          = ["never", "after"]

	let notifyTypeMenu: [String]        = ["never", "minute", "hour", "day", "week", "month", "quarter", "year"]
	let notifyTypeMenuPlurals: [String] = ["never", "minutes", "hours", "days", "weeks", "months", "quarters", "years"]
	let notifyModeMenu: [String]        = ["before", "after"]

//	var activeRowInComp1: Int = 0
	let maxNumberOfCases: Int = 99




	//MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		// Removes empty lines in the table
		addOrEditTable.tableFooterView = UIView()

		// To dismiss keyboard after a tap outside
		//		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
		//		self.view.addGestureRecognizer(tapGesture)

		setupAddTargetIsNotEmptyTextFields()

		repeatPicker.showsSelectionIndicator = true

		if let ev = addOrEditEvent {

			// EDIT EXISTING EVENT

			navigationBar.title = "Edit Event"
			addOrSaveButton.isEnabled = true

			titleTextField.text = ev.title!
			allDaySwitch.setOn(ev.allday, animated: true)

			theDate = ev.date! as Date

			theRepeatType = Int(ev.repeatType)
			theRepeatQuantity = Int(ev.repeatQuantity) - 1

			theEndRepeatType = Int(ev.endRepeatType)
			theEndRepeatQuantity = Int(ev.endRepeatQuantity) - 1

			theNotifyType = Int(ev.notifyType)
			theNotifyQuantity = Int(ev.notifyQuantity) - 1
			theNotifyMode = Int(ev.notifyMode)

		} else {

			// ADDING A NEW EVENT

			print("No event arrived here from AddOrEditController.")
			navigationBar.title = "New Event"
			addOrSaveButton.isEnabled = false

			titleTextField.text = ""
			allDaySwitch.setOn(true, animated: true)

			theDate = setAlldayEventToPrefTime(date: Date())
			titleTextField.becomeFirstResponder()
		}


		dateLabel.text = dateOnlyFormatter.string(from: theDate)
		timeLabel.text = timeOnlyFormatter.string(from: theDate)
		repeatLabel.text = repeatTextForRepeatLabel(repeatType: theRepeatType, repeatQuantity: theRepeatQuantity)
		endRepeatLabel.text = endRepeatTextForEndRepeatLabel(endRepeatType: theEndRepeatType, endRepeatQuantity: theEndRepeatQuantity)
		notifyLabel.text = notifyTextForNotifyLabel(notifyType: theNotifyType, notifyQuantity: theNotifyQuantity, notifyMode: theNotifyMode)

		datePicker.setDate(theDate, animated: true)
		timePicker.setDate(theDate, animated: true)
		repeatPicker.selectRow(theRepeatType, inComponent: 1, animated: true)
		repeatPicker.selectRow(theRepeatQuantity, inComponent: 0, animated: true)
		endRepeatPicker.selectRow(theEndRepeatType, inComponent: 0, animated: true)
		endRepeatPicker.selectRow(theEndRepeatQuantity, inComponent: 1, animated: true)
		notifyPicker.selectRow(theNotifyQuantity, inComponent: 0, animated: true)
		notifyPicker.selectRow(theNotifyType, inComponent: 1, animated: true)
		notifyPicker.selectRow(theNotifyMode, inComponent: 2, animated: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch(section) {
		case 0:
			return 1
		case 1:
			return 5
		case 2:
			return 4
		case 3:
			return 2
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		var heigth: CGFloat = 0.0

		if indexPath.section == 1 && indexPath.row == 2 {
			if datePickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else if indexPath.section == 1 && indexPath.row == 4 {
			if timePickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else if indexPath.section == 2 && indexPath.row == 1 {
			if repeatPickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else if indexPath.section == 2 && indexPath.row == 2 {
			if theRepeatType == 0 { heigth = 0.0 } else { heigth = 44.0 }
		} else if indexPath.section == 2 && indexPath.row == 3 {
			if endRepeatPickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else if indexPath.section == 3 && indexPath.row == 1 {
			if notifyPickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else if indexPath.section == 1 && indexPath.row == 3 {
			// TIME ;; if allday is true is 0.0 else 44.0
			if allDaySwitch.isOn { heigth = 0.0 } else { heigth = 44.0 }
		} else {
			heigth = 44.0
		}
		if datePickerIsVisible { datePicker.setValue(UIColor.white, forKey: "textColor") }
		if timePickerIsVisible { timePicker.setValue(UIColor.white, forKey: "textColor") }

		return heigth
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.beginUpdates()

		if indexPath.section == 1 && indexPath.row == 1 {
			datePickerIsVisible.toggle()
			if timePickerIsVisible { timePickerIsVisible = false }
			if repeatPickerIsVisible { repeatPickerIsVisible = false }
			if endRepeatPickerIsVisible { endRepeatPickerIsVisible = false }
			if notifyPickerIsVisible { notifyPickerIsVisible = false }
		} else if indexPath.section == 1 && indexPath.row == 3 {
			timePickerIsVisible.toggle()
			if datePickerIsVisible { datePickerIsVisible = false }
			if repeatPickerIsVisible { repeatPickerIsVisible = false }
			if endRepeatPickerIsVisible { endRepeatPickerIsVisible = false }
			if notifyPickerIsVisible { notifyPickerIsVisible = false }
		} else if indexPath.section == 2 && indexPath.row == 0 {
			// REPEAT CELL CLICKED
			repeatPickerIsVisible.toggle()
			if datePickerIsVisible { datePickerIsVisible = false }
			if timePickerIsVisible { timePickerIsVisible = false }
			if endRepeatPickerIsVisible { endRepeatPickerIsVisible = false }
			if notifyPickerIsVisible { notifyPickerIsVisible = false }
		} else if indexPath.section == 2 && indexPath.row == 2 {
			// END REPEAT CELL CLICKED
			endRepeatPickerIsVisible.toggle()
			if datePickerIsVisible { datePickerIsVisible = false }
			if timePickerIsVisible { timePickerIsVisible = false }
			if repeatPickerIsVisible { repeatPickerIsVisible = false }
			if notifyPickerIsVisible { notifyPickerIsVisible = false }
		} else if indexPath.section == 3 && indexPath.row == 0 {
			// NOTIFY CELL CLICKED
			notifyPickerIsVisible.toggle()
			if endRepeatPickerIsVisible { endRepeatPickerIsVisible = false }
			if datePickerIsVisible { datePickerIsVisible = false }
			if timePickerIsVisible { timePickerIsVisible = false }
			if repeatPickerIsVisible { repeatPickerIsVisible = false }
		}

		if datePickerIsVisible { dateLabel.textColor = UIColor.red } else { dateLabel.textColor = UIColor.white }
		if timePickerIsVisible { timeLabel.textColor = UIColor.red } else { timeLabel.textColor = UIColor.white }
		if repeatPickerIsVisible { repeatLabel.textColor = UIColor.red } else { repeatLabel.textColor = UIColor.white }
		if endRepeatPickerIsVisible { endRepeatLabel.textColor = UIColor.red } else { endRepeatLabel.textColor = UIColor.white }
		if notifyPickerIsVisible { notifyLabel.textColor = UIColor.red } else { notifyLabel.textColor = UIColor.white }

		addOrEditTable.reloadData()
		tableView.endUpdates()
	}




	
	// MARK: - REPEAT PICKER DATA MANAGEMENT

	func numberOfComponents(in pickerView: UIPickerView) -> Int {

		let tag = PickerTag(rawValue: pickerView.tag)!
		switch tag {

		case PickerTag.repeatTag:
			return 2

		case PickerTag.endRepeatTag:
			return 3

		case PickerTag.notifyTag:
			return 3
		}

	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		let tag = PickerTag(rawValue: pickerView.tag)!
		switch tag {

		case PickerTag.repeatTag:
			if component == 0 { return theRepeatType == 0 ? 1 : maxNumberOfCases } else { return repeats.count }

		case PickerTag.endRepeatTag:
			if component == 0 { return endRepatMenu.count }
			if component == 1 { return theEndRepeatType == 0 ? 1 : 100 }
			if component == 2 { return theEndRepeatType == 0 ? 1 : 1 }
			endRepeatPicker.reloadAllComponents()

		case PickerTag.notifyTag:
			if component == 0 {
				return theNotifyType == 0 ? 1 : 100
			} else if component == 1 {
				return notifyTypeMenu.count
			} else if component == 2 {
				return notifyModeMenu.count
			} else {
				return 0
			}
		}
		return 0
	}


	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

		var res = ""
		let tag = PickerTag(rawValue: pickerView.tag)!

		switch tag {

		case PickerTag.repeatTag:
			if component == 0 { res = theRepeatType == 0 ? "–" : String(row + 1) } else { res = repeats[row] }

		case PickerTag.endRepeatTag:
			if component == 0 {
				res = endRepatMenu[row]
			} else if component == 1 {
				res = theEndRepeatType == 0 ? "" : String(row + 1)
			} else {
				res = theEndRepeatType == 0 ? "" : theEndRepeatQuantity > 0 ? "times" : "time"
			}
		case PickerTag.notifyTag:
			if component == 0 {
				res = theNotifyType == 0 ? "–" : String(row + 1)
			} else if component == 1 {
				res = notifyTypeMenu[row]
			} else {
				res = notifyModeMenu[row]
			}
		}

//		let fontName = titleTextField.font!.fontName
//		let font = UIFont(name: fontName, size: CGFloat(12.0))

		let attRes = NSAttributedString(string: res, attributes: [NSForegroundColorAttributeName: UIColor.white])

		return attRes
	}

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

		let tag = PickerTag(rawValue: pickerView.tag)!

		switch tag {

		case PickerTag.repeatTag:
			if component == 0 { return 50.0 } else { return 150.0 }
		case PickerTag.endRepeatTag:
			if component == 0 {
				return 110.0
			} else if component == 1 {
				return 50.0
			} else {
				return 70.0
			}

		case PickerTag.notifyTag:
			if component == 0 {
				return 50.0
			} else if component == 1 {
				return 110.0
			} else {
				return 110.0
			}
		}
	}


	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

		let tag = PickerTag(rawValue: pickerView.tag)!

		switch tag {

		case PickerTag.repeatTag:
			if component == 1 {
				theRepeatType = row
				repeatPicker.reloadAllComponents()
			}

			let repeatQuantity = repeatPicker.selectedRow(inComponent: 0)
			let repeatType = repeatPicker.selectedRow(inComponent: 1)

			repeatLabel.text = repeatTextForRepeatLabel(repeatType: repeatType, repeatQuantity: repeatQuantity)

		case PickerTag.endRepeatTag:
			if component == 0 { theEndRepeatType = row }
			if component == 1 { theEndRepeatQuantity = row }
			endRepeatPicker.reloadAllComponents()

			endRepeatLabel.text = endRepeatTextForEndRepeatLabel(endRepeatType: theEndRepeatType, endRepeatQuantity: theEndRepeatQuantity)

		case PickerTag.notifyTag:
			if component == 1 {
				theNotifyType = row
				notifyPicker.reloadAllComponents()
			}

			let notifyType     = notifyPicker.selectedRow(inComponent: 1)
			let notifyQuantity = notifyPicker.selectedRow(inComponent: 0)
			let notifyMode     = notifyPicker.selectedRow(inComponent: 2)

			notifyLabel.text = notifyTextForNotifyLabel(notifyType: notifyType, notifyQuantity: notifyQuantity, notifyMode: notifyMode)
		}
	}



	// MARK: - Other

	func displayDate(date: Date) {

		dateLabel.text = dateOnlyFormatter.string(from: date)
		timeLabel.text = timeOnlyFormatter.string(from: date)

		datePicker.setDate(date, animated: true)
		timePicker.setDate(date, animated: true)
	}


	@IBAction func allDaySwitchClicked(_ sender: Any) {

		tableView.beginUpdates()

		if allDaySwitch.isOn {
			let myDate = setAlldayEventToPrefTime(date: datePicker.date)
			datePicker.date = myDate
			timePicker.date = myDate
			timeLabel.text = timeOnlyFormatter.string(from: myDate)

			timePickerIsVisible = false
			timeLabel.textColor = UIColor.white
		}
		
		addOrEditTable.reloadData()
		tableView.endUpdates()
	}

	func syncDateAndTimePickers() {

		let d1     = datePicker.date
		let d2     = timePicker.date
		let year   = d1.year
		let month  = d1.month
		let day    = d1.day
		let hour   = d2.hour
		let minute = d2.minute

		let mergedDateAndTime = dateAndTimeFormatter.date(from: "\(day)-\(month)-\(year) \(hour):\(minute)")

		if let date = mergedDateAndTime {
			datePicker.date = date
			timePicker.date = date
		}
	}


	@IBAction func datePickerValueChanged(_ sender: Any) {

		theDate = datePicker.date
		dateLabel.text = dateOnlyFormatter.string(from: theDate)

		syncDateAndTimePickers()
	}

	@IBAction func timePickerValueChanged(_ sender: Any) {

		theDate = timePicker.date
		timeLabel.text = timeOnlyFormatter.string(from: theDate)

		syncDateAndTimePickers()
	}

	@IBAction func cancelButtonClicked(_ sender: Any) {
		debugPrint("Cancel button pressed")
	}

	@IBAction func addOrSaveButtonClicked(_ sender: Any) {
		debugPrint("Add or Save button pressed")
	}


	// MARK: - SEGUE Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if sender is UIBarButtonItem {

			let clickedButton     = sender as! UIBarButtonItem
			let buttonTag         = clickedButton.tag

			let repeatQuantity    = repeatPicker.selectedRow(inComponent: 0) + 1
			let repeatType        = repeatPicker.selectedRow(inComponent: 1)
			let endRepeatType     = endRepeatPicker.selectedRow(inComponent: 0)
			let endRepeatQuantity = endRepeatPicker.selectedRow(inComponent: 1) + 1
			let title             = titleTextField.text!.trimmingCharacters(in: .whitespaces)
			let notifyType        = notifyPicker.selectedRow(inComponent: 1)
			let notifyQuantity    = notifyPicker.selectedRow(inComponent: 0) + 1
			let notifyMode        = notifyPicker.selectedRow(inComponent: 2)
			
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

			theResult = Result(
				action: action,
				title: title,
				date: theDate,
				allday: allDaySwitch.isOn,
				repeatType: repeatType,
				repeatQuantity: repeatQuantity,
				endRepeatType: endRepeatType,
				endRepeatQuantity: endRepeatQuantity,
				notifyType: notifyType,
				notifyQuantity: notifyQuantity,
				notifyMode: notifyMode
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

		// addOrSaveButton.isEnabled = false
		titleTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
	}

	func textFieldsIsNotEmpty(sender: UITextField) {

		if let str = sender.text?.trimmingCharacters(in: .whitespaces) {
			self.addOrSaveButton.isEnabled = !str.isEmpty
		}
	}


}
