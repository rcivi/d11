//
//  Event.swift
//  D10
//
//  Created by Ruggero Civitarese on 15/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import Foundation
import SwiftDate
import UserNotifications



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
	case never   = 0
	case minute  = 1
	case hour    = 2
	case day     = 3
	case week    = 4
	case month   = 5
	case quarter = 6
	case year    = 7
}

enum Mode: Int {
	case before = 0
	case after  = 1
}

enum ActionToReturn {
	case canceled
	case edited
	case added
}

enum PickerTag: Int {
	case repeatTag    = 1
	case endRepeatTag = 2
	case notifyTag    = 3
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


	init(action: ActionToReturn,
		title: String,
		date: Date,
		allday: Bool = true,
		repeatType: Int = 0,
		repeatQuantity: Int = 0,
		endRepeatType: Int = 0,
		endRepeatQuantity: Int = 0,
		notifyType: Int = 0,
		notifyQuantity: Int = 0,
		notifyMode: Int = 0
		) {

		self.action            = action
		self.title             = title
		self.date              = date
		self.allday            = allday
		self.repeatType        = repeatType
		self.repeatQuantity    = repeatQuantity
		self.endRepeatType     = endRepeatType
		self.endRepeatQuantity = endRepeatQuantity
		self.notifyType        = notifyType
		self.notifyQuantity    = notifyQuantity
		self.notifyMode        = notifyMode
	}
}

// MARK: - PREFERENCES VARIABLES

var colloquialIsOn: Bool          = false
var normalColor: UIColor          = .white
var attentionColor: UIColor       = .orange
var alarmColor: UIColor           = .red
var titleFontSize: Float          = 20
var detailFontSize: Float         = 13
var animateTableIsOn: Bool        = true
var notificationIdCounter: Int    = 0
var alldayNotificationMinute: Int = 9 * 60

enum PrefsKey: String {
	case colloquialKey               = "colloquial"
	case normalColorKey              = "normalColor"
	case attentioncolorKey           = "attentionColor"
	case alertColorKey               = "alertColor"
	case titleFontSizeKey            = "titleFontSize"
	case detailFontSizeKey           = "detailFontSize"
	case animateTableIsOnKey         = "animateTableIsOn"
	case sortEventsByKey             = "sortEventsBy"
	case notificationIdCounterKey    = "notificationIdCounter"
	case alldayNotificationMinuteKey = "alldaNotificationMinute"
}

enum SortEventsBy: Int {
	case date = 0
	case title = 1
}


extension Bool {
	/// EZSE: Converts Bool to Int.
	public var toInt: Int { return self ? 1 : 0 }

	/// EZSE: Toggle boolean value.
	@discardableResult
	public mutating func toggle() -> Bool {
		self = !self
		return self
	}

	/// EZSE: Return inverted value of bool.
	public var toggled: Bool {
		return !self
	}
}


public extension Date {
	/// SwiftRandom extension
	public static func randomWithinDaysBeforeToday(_ days: Int) -> Date {
		let today = Date()
		let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

		let r1 = arc4random_uniform(UInt32(days))
		let r2 = arc4random_uniform(UInt32(23))
		let r3 = arc4random_uniform(UInt32(59))
		let r4 = arc4random_uniform(UInt32(59))

		var offsetComponents = DateComponents()
		offsetComponents.day    = Int(r1) * -1
		offsetComponents.hour   = Int(r2)
		offsetComponents.minute = Int(r3)
		offsetComponents.second = Int(r4)

		guard let rndDate1 = gregorian.date(byAdding: offsetComponents, to: today) else {
			print("randoming failed")
			return today
		}
		return rndDate1
	}

	/// SwiftRandom extension
	public static func random() -> Date {
		let randomTime = TimeInterval(arc4random_uniform(UInt32.max))
		return Date(timeIntervalSince1970: randomTime)
	}

}

class ColoredDatePicker: UIDatePicker {
	var changed = false
	override func addSubview(_ view: UIView) {
		if !changed {
			changed = true
			self.setValue(UIColor.white, forKey: "textColor")
		}
		super.addSubview(view)
	}
}

// MARK: - COLOR DEFINITION

extension UIColor {
	public class var editSwipeBackground: UIColor { return UIColor(red: 3/255, green: 177/255, blue: 0/255, alpha: 1.0) }
}


extension MainController: UNUserNotificationCenterDelegate {

	func calculateNotificationDate(event: Event) -> Date {

		var notificationDate = event.rolledDate! as Date
		var quantity = 0.minute
		let type = Every.init(rawValue: Int(event.notifyType)) ?? Every.never
		let mode = Mode.init(rawValue: Int(event.notifyMode)) ?? Mode.before

		print("\(event.title!): \(event.notifyQuantity)")

		switch type {
		case Every.never: break
		case Every.minute: quantity  = Int(event.notifyQuantity).minute
		case Every.hour: quantity    = Int(event.notifyQuantity).hour
		case Every.day: quantity     = Int(event.notifyQuantity).day
		case Every.week: quantity    = Int(event.notifyQuantity).week
		case Every.month: quantity   = Int(event.notifyQuantity).month
		case Every.quarter: quantity = (Int(event.notifyQuantity) * 3).month
		case Every.year: quantity    = Int(event.notifyQuantity).year
		}

		switch mode {
		case .before: notificationDate = notificationDate - quantity
		case .after: notificationDate = notificationDate + quantity
		}

		return notificationDate
	}


	func sendNotification(event: Event) {

		guard Int(event.notifyType) != 0 else { return }
		guard let nd = event.notificationDate else { return }
		
		let notificationDate = nd as Date
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
		let content = UNMutableNotificationContent()
		content.title = "Title"
		content.subtitle = "Subtitle"
		content.body = event.title!
		content.sound = UNNotificationSound.default()
		//			content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1);
		content.categoryIdentifier = "it.rug.localNotification"


		// GESTIRE IL REPEAT!!!
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		let request = UNNotificationRequest.init(identifier: event.notificationId!, content: content, trigger: trigger)

		let center = UNUserNotificationCenter.current()
		center.add(request)
	}


	// TO RECEIVE FOREGROUND NOTIFICATIONS
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		completionHandler([.alert, .sound])
	}

}


func repeatTextForRepeatLabel(repeatType: Int, repeatQuantity: Int) -> String {

	let repeats: [String]        = ["never", "minute", "hour", "day", "week", "month", "quarter", "year"]
	let repeatsPlurals: [String] = ["never", "minutes", "hours", "days", "weeks", "months", "quarters", "years"]

	let repeatQuantityString = repeatType     == 0 ? "" : String(repeatQuantity + 1)
	let repeatTypeString     = repeatQuantity == 0 ? repeats[repeatType] : repeatsPlurals[repeatType]
	let everyString          = repeatType     == 0 ? "" : "every"

	return "\(everyString) \(repeatQuantityString) \(repeatTypeString)".trimmingCharacters(in: .whitespaces)
}

func endRepeatTextForEndRepeatLabel(endRepeatType: Int, endRepeatQuantity: Int) -> String {

	let endRepatMenu: [String] = ["never", "after"]

	let endRepeatQuantityStr   = endRepeatType == 0    ? "" : String(endRepeatQuantity + 1)
	let endRepeatPostLabel     = endRepeatQuantity > 0 ? "times" : "time"
	let endRepeatQuantityLabel = endRepeatType == 0    ? "" : endRepeatPostLabel
	let endRepeatType          = endRepatMenu[endRepeatType]

	return "\(endRepeatType) \(endRepeatQuantityStr) \(endRepeatQuantityLabel)".trimmingCharacters(in: .whitespaces)
}

func notifyTextForNotifyLabel(notifyType: Int, notifyQuantity: Int, notifyMode: Int) -> String {

	let notifyTypeMenu: [String]        = ["never", "minute", "hour", "day", "week", "month", "quarter", "year"]
	let notifyTypeMenuPlurals: [String] = ["never", "minutes", "hours", "days", "weeks", "months", "quarters", "years"]
	let notifyModeMenu: [String]        = ["before", "after"]

	let notifyQuantityStr = notifyType == 0    ? "" : String(notifyQuantity + 1)
	let notifyModeStr     = notifyType == 0    ? "" : notifyModeMenu[notifyMode]
	let notifyTypeStr     = notifyQuantity > 0 ? notifyTypeMenuPlurals[notifyType] : notifyTypeMenu[notifyType]

	return "\(notifyQuantityStr) \(notifyTypeStr) \(notifyModeStr)".trimmingCharacters(in: .whitespaces)
}


func setAlldayEventToPrefTime(date: Date) -> Date {

	let year   = date.year
	let month  = date.month
	let day    = date.day
	let hour   = alldayNotificationMinute / 60
	let minute = alldayNotificationMinute % 60

	if let myDateAt9 = dateAndTimeFormatter.date(from: "\(day)-\(month)-\(year) \(hour):\(minute)") {
		return myDateAt9
	} else {
		return date
	}
}
