//
//  RepeatController.swift
//  D11
//
//  Created by Ruggero Civitarese on 08/02/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit

class RepeatController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	var activeRowInComp1: Int = 0
	let maxNumberOfCases: Int = 99
	var repeatPickerIsVisible: Bool = false

	let repeats: [String] = ["never", "hour", "day", "week", "month", "quarter", "year"]


	@IBOutlet weak var repeatPicker: UIPickerView!
	@IBOutlet var repeatTable: UITableView!
	@IBOutlet weak var repeatDetailLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

		repeatPickerIsVisible = false

		// Removes empty lines in the table
		repeatTable.tableFooterView = UIView()

	}

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 2
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		var heigth: CGFloat = 0.0

		if indexPath.section == 0 && indexPath.row == 1 { heigth = repeatPickerIsVisible ? 238.0 : 0.0 } else { heigth = 44.0 }

		return heigth
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		repeatTable.beginUpdates()

		if indexPath.section == 0 && indexPath.row == 0 {
			repeatPickerIsVisible = !repeatPickerIsVisible
		}

		if repeatPickerIsVisible { repeatDetailLabel.textColor = UIColor.red } else { repeatDetailLabel.textColor = UIColor.black }

		repeatTable.reloadData()
		repeatTable.endUpdates()
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



}
