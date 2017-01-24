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

var dateAndTimeFormatter: DateFormatter {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "d-M-yyyy HH:mm"
	return dateFormatter
}

enum Every: Int {
	case never = 0
	case day   = 1
	case week  = 2
	case month = 3
	case year  = 4
}

enum ActionToReturn {
	case canceled
	case edited
	case added
}

struct Result {

	var action: ActionToReturn
	var title: String
	var date: String
	var allday: Bool
	var repeatition: Bool
	var every: Every
//	var rolledDate: Date
	
	
	init(action: ActionToReturn, title: String, date: String, allday: Bool, repeatition: Bool, every: Every) {
		self.action = action
		self.title = title
		self.date = date
		self.allday = allday
		self.repeatition = repeatition
		self.every = every
	}
}
