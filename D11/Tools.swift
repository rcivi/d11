//
//  Event.swift
//  D10
//
//  Created by Ruggero Civitarese on 15/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import Foundation
import SwiftDate


var dateOnlyFormatter: DateFormatter {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "d-M-yyyy"
	return dateFormatter
}

var timeOnlyFormatter: DateFormatter {
	let timeFormatter = DateFormatter()
	timeFormatter.dateFormat = "HH:mm"
	return timeFormatter
}

var dateAndTimeFormatter: DateFormatter {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "d-M-yyyy HH:mm"
	return dateFormatter
}

enum Every: Int {
	case never = 0
	case hour = 1
	case day   = 2
	case week  = 3
	case month = 4
	case quarter = 5
	case year  = 6
}

enum Mode: Int {
	case before = 0
	case after = 1
}

enum ActionToReturn {
	case canceled
	case edited
	case added
}

enum PickerTag: Int {
	case repeatTag = 1
	case endRepeatTag = 2
	case notifyTag = 3
}


struct Result {

	var action: ActionToReturn
	var title: String
	var date: Date
	var allday: Bool
	var repeatType: Int
	var repeatQuantity: Int
	var endRepeatType: Int
	var endRepeatQuantity: Int
	var notifyType: Int
	var notifyQuantity: Int
	var notifyMode: Int

	
	init(action: ActionToReturn, title: String, date: Date, allday: Bool = true, repeatType: Int = 0, repeatQuantity: Int = 0, endRepeatType: Int = 0, endRepeatQuantity: Int = 0, notifyType: Int = 0, notifyQuantity: Int = 0, notifyMode: Int = 0) {
		self.action = action
		self.title = title
		self.date = date
		self.allday = allday
		self.repeatType = repeatType
		self.repeatQuantity = repeatQuantity
		self.endRepeatType = endRepeatType
		self.endRepeatQuantity = endRepeatQuantity
		self.notifyType = notifyType
		self.notifyQuantity = notifyQuantity
		self.notifyMode = notifyMode
	}
}

// MARK: - PREFERENCES VARIABLES

var colloquialIsOn: Bool = false
var normalColor: UIColor = .black
var attentionColor: UIColor = .orange
var alarmColor: UIColor = .red
var titleFontSize: Float = 20
var detailFontSize: Float = 13


enum PrefsKey: String {
	case colloquialKey = "colloquial"
	case normalColorKey = "normalColor"
	case attentioncolorKey = "attentionColor"
	case alertColorKey = "alertColor"
	case titleFontSizeKey = "titleFontSize"
	case detailFontSizeKey = "detailFontSize"
}

