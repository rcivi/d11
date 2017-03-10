//
//  PreferencesController.swift
//  D11
//
//  Created by Ruggero Civitarese on 15/02/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit
import Fakery


class OldPreferencesController: UIViewController {

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
		animationSwitch.isOn = defaults.bool(forKey: PrefsKey.animateTableIsOnKey.rawValue)
		titleSlider.value = defaults.value(forKey: PrefsKey.titleFontSizeKey.rawValue) as? Float ?? 20.0
		detailSlider.value = defaults.value(forKey: PrefsKey.detailFontSizeKey.rawValue) as? Float ?? 13.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

	@IBAction func titleSliderChanged(_ sender: Any) {

		let slider = sender as! UISlider
		slider.value = round(slider.value)

		let size = NSNumber(value: Double(slider.value))
		let font = titleTextExampleLabel.font.fontName

		titleTextExampleLabel.font = UIFont(name: font, size: CGFloat(size))
	}

	@IBAction func detailSlider(_ sender: Any) {

		let slider = sender as! UISlider
		slider.value = round(slider.value)

		let size = NSNumber(value: Double(slider.value))
		let font = detailTextExampleLabel.font.fontName

		detailTextExampleLabel.font = UIFont(name: font, size: CGFloat(size))
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		debugPrint("Leaving Preferences")
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

	@IBAction func generateFakeDataButtonPressed(_ sender: Any) {

		let alert = UIAlertController()

		alert.addAction(UIAlertAction(title: "Title", style: .default, handler: { (action) in
			print("Title")
		}))


		alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { (action) in
			print("Date")
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			print("cancel")
		}))

		self.present(alert, animated: true, completion: nil)
	}
	
}
