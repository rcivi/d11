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

enum ActionToReturn {
	case canceled
	case edited
	case added
}

enum PickerTag: Int {
	case repeatTag = 1
	case endRepeatTag = 2
}


struct Result {

	var action: ActionToReturn
	var title: String
	var date: Date
	var allday: Bool
//	var repeatition: Bool
//	var every: Every
	var repeatType: Int
	var repeatQuantity: Int
	var endRepeatType: Int
	var endRepeatQuantity: Int
//	var rolledDate: Date
	
	
	init(action: ActionToReturn, title: String, date: Date, allday: Bool, repeatType: Int, repeatQuantity: Int, endRepeatType: Int, endRepeatQuantity: Int) {
		self.action = action
		self.title = title
		self.date = date
		self.allday = allday
		self.repeatType = repeatType
		self.repeatQuantity = repeatQuantity
		self.endRepeatType = endRepeatType
		self.endRepeatQuantity = endRepeatQuantity
	}
}
