//
//  Event.swift
//  D10
//
//  Created by Ruggero Civitarese on 15/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import Foundation
import SwiftDate

enum Every: Int {
	case never = 0
	case day   = 1
	case week  = 2
	case month = 3
	case year  = 4
}




class Event {

	var title: String
	var date: DateInRegion

	
	init(title: String, date: DateInRegion) {
		self.title = title
		self.date = date
	}
}
