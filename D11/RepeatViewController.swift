//
//  RepeatViewController.swift
//  
//
//  Created by Ruggero Civitarese on 06/02/17.
//
//

import UIKit

class RepeatViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	var activeRowInComp1: Int = 0
	let maxNumberOfCases: Int = 99
	var repeatPickerIsVisible: Bool = false

	@IBOutlet weak var repeatPicker: UIPickerView!

	let repeats: [String] = ["never", "hour", "day", "week", "month", "quarter", "year"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

		repeatPicker.selectRow(3, inComponent: 0, animated: true)
		repeatPicker.selectRow(3, inComponent: 1, animated: true)
		activeRowInComp1 = 3
//		repeatPicker.reloadAllComponents()
    }

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    

	// MARK: - TABLE

	override func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

			return 2
	}


	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		var heigth: CGFloat = 0.0

		if indexPath.section == 0 && indexPath.row == 0 {
			if repeatPickerIsVisible { heigth = 238.0 } else { heigth = 0.0 }
		} else {
			heigth = 44.0
		}
		return heigth
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//		tableView.beginUpdates()
//
//		if indexPath.section == 1 && indexPath.row == 1 {
//			datePickerIsVisible = !datePickerIsVisible
//			if timePickerIsVisible { timePickerIsVisible = false }
//		} else if indexPath.section == 1 && indexPath.row == 3 {
//			timePickerIsVisible = !timePickerIsVisible
//			if datePickerIsVisible { datePickerIsVisible = false }
//		} else if indexPath.section == 2 && indexPath.row == 0 {
//			// REPEAT CELL CLICKED
//			debugPrint("Leaving from AddOrSave to Repeat")
//			performSegue(withIdentifier: "repeatSegue", sender: self)
//		} else if indexPath.section == 2 && indexPath.row == 1 {
//			// END REPEAT CELL CLICKED
//		}
//
//		if datePickerIsVisible { dateLabel.textColor = UIColor.red } else { dateLabel.textColor = UIColor.black }
//		if timePickerIsVisible { timeLabel.textColor = UIColor.red } else { timeLabel.textColor = UIColor.black }
//
//		addOrEditTable.reloadData()
//		tableView.endUpdates()
	}



	// MARK: - PICKER

	func numberOfComponents(in pickerView: UIPickerView) -> Int {

		return 2
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		if component == 0 {
			return activeRowInComp1 == 0 ? 1 : maxNumberOfCases
		} else {
			return repeats.count
		}
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

		if component == 0 {
			return activeRowInComp1 == 0 ? "–" : String(row + 1)
		} else {
			return repeats[row]
		}
	}

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

		if component == 0 {
			return 50.0
		} else {
			return 150.0
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

		if component == 1 {
			activeRowInComp1 = row
			repeatPicker.reloadAllComponents()
		}
	}


	@IBAction func testButtonClicked(_ sender: AnyObject) {

		let alert = UIAlertController(title: "AlertController Tutorial", message: "Submit something", preferredStyle: .alert)

		// Submit button
		let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
			// Get 1st TextField's text
			let textField = alert.textFields![0]
			print(textField.text!)
		})

		// Cancel button
		let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
		// Add 1 textField and customize it
		alert.addTextField { (textField: UITextField) in
			textField.keyboardAppearance = .dark
			textField.keyboardType = .default
			textField.autocorrectionType = .default
			textField.placeholder = "Type something here"
			textField.clearButtonMode = .whileEditing
		}

		// Add action buttons and present the Alert
		alert.addAction(submitAction)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)

	}

}
