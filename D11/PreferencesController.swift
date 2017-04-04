//
//  PreferencesController.swift
//  D11
//
//  Created by Ruggero Civitarese on 10/03/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit
import Fakery
import UserNotifications

class PreferencesController: UITableViewController {

	@IBOutlet weak var colloquialSwitch: UISwitch!
	@IBOutlet weak var animationSwitch: UISwitch!
	@IBOutlet weak var titleSlider: UISlider!
	@IBOutlet weak var detailSlider: UISlider!
	@IBOutlet weak var titleTextExampleLabel: UILabel!
	@IBOutlet weak var detailTextExampleLabel: UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()

		let defaults = UserDefaults.standard
		colloquialSwitch.isOn = defaults.bool(forKey: PrefsKey.colloquialKey.rawValue)
		animationSwitch.isOn  = defaults.bool(forKey: PrefsKey.animateTableIsOnKey.rawValue)
		titleSlider.value     = defaults.value(forKey: PrefsKey.titleFontSizeKey.rawValue) as? Float ?? 20.0
		detailSlider.value    = defaults.value(forKey: PrefsKey.detailFontSizeKey.rawValue) as? Float ?? 13.0

		let tsize = NSNumber(value: Double(titleSlider.value))
		let tfont = titleTextExampleLabel.font.fontName
		titleTextExampleLabel.font = UIFont(name: tfont, size: CGFloat(tsize))

		let dsize = NSNumber(value: Double(detailSlider.value))
		let dfont = detailTextExampleLabel.font.fontName
		detailTextExampleLabel.font = UIFont(name: dfont, size: CGFloat(dsize))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 2
		case 1:
			return 2
		case 2:
			return 1
		default:
			return 0
		}
    }


	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		savePreferences()
	}

	func savePreferences() {

		let defaults = UserDefaults.standard
		defaults.set(colloquialSwitch.isOn, forKey: PrefsKey.colloquialKey.rawValue)
		defaults.set(animationSwitch.isOn, forKey: PrefsKey.animateTableIsOnKey.rawValue)
		defaults.setValue(titleSlider.value, forKey: PrefsKey.titleFontSizeKey.rawValue)
		defaults.setValue(detailSlider.value, forKey: PrefsKey.detailFontSizeKey.rawValue)
		defaults.set(SortEventsBy.date.rawValue, forKey: PrefsKey.sortEventsByKey.rawValue)
	}


	@IBAction func titleSliderChanged(_ sender: Any) {

		let slider = sender as! UISlider
		slider.value = round(slider.value)

		let size = NSNumber(value: Double(slider.value))
		let font = titleTextExampleLabel.font.fontName

		titleTextExampleLabel.font = UIFont(name: font, size: CGFloat(size))
	}

	@IBAction func detailSliderChanged(_ sender: Any) {

		let slider = sender as! UISlider
		slider.value = round(slider.value)

		let size = NSNumber(value: Double(slider.value))
		let font = detailTextExampleLabel.font.fontName

		detailTextExampleLabel.font = UIFont(name: font, size: CGFloat(size))
	}

	@IBAction func generateFakeDataButtonPressed(_ sender: Any) {

		let alert = UIAlertController()

		alert.addAction(UIAlertAction(title: "Remove all notifications", style: .default, handler: { (action) in
			let center = UNUserNotificationCenter.current()
			center.removeAllDeliveredNotifications()
			center.removeAllPendingNotificationRequests()
		}))


		alert.addAction(UIAlertAction(title: "List all notifications", style: .default, handler: { (action) in
			let center = UNUserNotificationCenter.current()
			center.getPendingNotificationRequests(completionHandler: { requests in
				print("Pending notifications (\(requests.count))")
				for request in requests {
					print(request)
				}
			})
			center.getDeliveredNotifications(completionHandler: { delivereds in
				print("Delivered notifications (\(delivereds.count))")
				for delivered in delivereds {
					print(delivered)
				}
			})
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			print("cancel")
		}))

		self.present(alert, animated: true, completion: nil)
	}
	
}
