//
//  MainController.swift
//  D11
//
//  Created by Ruggero Civitarese on 18/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate
import UserNotifications
import Fakery


class EventCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detail1Label: UILabel!
	@IBOutlet weak var detail2Label: UILabel!
}




class MainController: UITableViewController {

	@IBOutlet var eventsTable: UITableView!

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var managedObjectContext: NSManagedObjectContext?

	var badgeCount: Int = 0
	var events = [Event]()


	var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}



	// MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

		// Working directory of the simulator
//		let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//		print("Simulator working direcotry: \(dirPaths[0])")

		// Removes empty lines in the table
		eventsTable.tableFooterView = UIView()

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		managedObjectContext = appDelegate.persistentContainer.viewContext

//		self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)

		self.refreshControl?.addTarget(self, action: #selector(MainController.handleRefresh) , for: UIControlEvents.valueChanged)

		createInitialRecords()

		loadPreferences()
		loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - TABLE VIEW DATA SOURCE

	override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return events.count }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellIdentifier", for: indexPath) as! EventCell




		let today = Date()
		let ev = events[indexPath.row]

//		print("EVENTO APPENA CARICATO")
//		print(ev)

		guard let tit = ev.value(forKey: "title") as? String else { print("Title error"); return cell }
		guard let dt1 = ev.value(forKey: "date") as? Date else { print("Date error"); return cell }
		guard let evrN = ev.value(forKey: "repeatType") as? Int else { print("Every Type error"); return cell }
		guard let evrQN = ev.value(forKey: "repeatQuantity") as? Int else { print("Every Quantity error"); return cell }

		guard let ert = ev.value(forKey: "endRepeatType") as? Int else { print("Repeat Type error"); return cell }
		guard let erq = ev.value(forKey: "endRepeatQuantity") as? Int else { print("Repeat Quantity Type error"); return cell }

		guard let nt = ev.value(forKey: "notifyType") as? Int else { print("Repeat Type error"); return cell }
		guard let nq = ev.value(forKey: "notifyQuantity") as? Int else { print("Repeat Type error"); return cell }
		guard let nm = ev.value(forKey: "notifyMode") as? Int else { print("Repeat Type error"); return cell }


		let evr = Every(rawValue: evrN)!

		let (newDate, colloquial) = dateDistanceFromNow(toDate: dt1, repeatType: evr, repeatQuantity: evrQN, endRepeatType: ert, endRepeatQuantity: erq)

		let debugString = "\(tit), \(colloquial) - DB: \(dt1) - Rpt: \(newDate) - (T\(evrN),Q\(evrQN),ER\(erq)) - Now: \(today)"
		debugPrint(debugString)

		cell.titleLabel.text = tit
		cell.detail1Label.text = colloquialIsOn ? colloquial : dateAndTimeFormatter.string(from: newDate)   // "\(newDate)"
		cell.detail2Label.text = ""

		let font = cell.titleLabel.font.fontName
		let size = NSNumber(value: Double(titleFontSize))
		cell.titleLabel.font = UIFont(name: font, size: CGFloat(size))

		let font1 = cell.detail1Label.font.fontName
		let size1 = NSNumber(value: Double(detailFontSize))
		cell.detail1Label.font = UIFont(name: font1, size: CGFloat(size1))


		let notificationDate = getNotificationDate(date: newDate, notifyType: nt, notifyQuantity: nq, notifyMode: nm)
		cell.detail1Label.textColor = getTextLabelColor(notifyMode: nm, notificationDate: notificationDate, eventDate: newDate)


		return cell
	}


	// MARK: - DATE MANAGEMENT

	func getTextLabelColor(notifyMode: Int, notificationDate: Date, eventDate: Date) -> UIColor {

		let nmode = Mode(rawValue: notifyMode)!
		var returnColor = normalColor
		let today = Date()

		switch nmode {

		case Mode.before:
			if today < notificationDate {
				returnColor = normalColor
			} else if today >= notificationDate && today < eventDate {
				returnColor = attentionColor
			} else if today >= eventDate {
				returnColor = alarmColor
			}

		case Mode.after:
			if today < eventDate {
				returnColor = normalColor
			} else if today >= eventDate && today < notificationDate {
				returnColor = attentionColor
			} else if today >= notificationDate {
				returnColor = alarmColor
			}

		}

		return returnColor
	}


	func getNotificationDate(date: Date, notifyType: Int, notifyQuantity: Int, notifyMode: Int) -> Date {

		var notificationDate = date
		let notificationQuantity = notifyQuantity + 1
		let notificationType = Every(rawValue: notifyType)!
		let notificationMode = Mode(rawValue: notifyMode)!

		switch(notificationType) {

		case Every.never:
			break
		case Every.hour:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - notificationQuantity.hour
			case Mode.after: notificationDate = notificationDate + notificationQuantity.hour
			}

		case Every.day:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - notificationQuantity.day
			case Mode.after: notificationDate = notificationDate + notificationQuantity.day
			}

		case Every.week:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - notificationQuantity.week
			case Mode.after: notificationDate = notificationDate + notificationQuantity.week
			}

		case Every.month:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - notificationQuantity.month
			case Mode.after: notificationDate = notificationDate + notificationQuantity.month
			}

		case Every.quarter:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - (notificationQuantity * 3).month
			case Mode.after: notificationDate = notificationDate + (notificationQuantity * 3).month
			}

		case Every.year:
			switch(notificationMode) {
			case Mode.before: notificationDate = notificationDate - notificationQuantity.year
			case Mode.after: notificationDate = notificationDate + notificationQuantity.year
			}

		}
		
		return notificationDate
	}


	func dateDistanceFromNow(toDate: Date, repeatType: Every, repeatQuantity: Int, endRepeatType: Int, endRepeatQuantity: Int) -> (Date, String) {

		let newDate = rollDate(startDate: toDate, repeatType: repeatType, repeatQuantity: repeatQuantity, endRepeatType: endRepeatType, endRepeatQuantity: endRepeatQuantity)
		var stringResult: String = ""

		do {
			let (colloquial,_) = try newDate.colloquialSinceNow()
			stringResult = colloquial
		} catch {
			print("Error converting to colloquial")
			stringResult = ""
		}
		return (newDate, stringResult)
	}


	func rollDate(startDate: Date, repeatType: Every, repeatQuantity: Int, endRepeatType: Int, endRepeatQuantity: Int) -> Date {

		var newDate = startDate
		let rquantity = repeatQuantity + 1 // To change from position to value
		let erquantity = endRepeatType == 0 ? 0 : endRepeatQuantity

		var countRepetitions = 0

		if newDate.isInPast && repeatType != Every.never {
			while newDate.isBefore(date: Date(), granularity: .second) && countRepetitions <= erquantity {

				countRepetitions += endRepeatType == 0 ? 0 : 1

				switch(repeatType) {

				case Every.never:
					break
				case Every.hour:
					newDate = newDate + rquantity.hour
				case Every.day:
					newDate = newDate + rquantity.day
				case Every.week:
					newDate = newDate + rquantity.week
				case Every.month:
					newDate = newDate + rquantity.month
				case Every.quarter:
					newDate = newDate + (rquantity * 3).month
				case Every.year:
					newDate = newDate + rquantity.year
				}
			}
		}
		return newDate
	}


	// MARK: - CORE DATA MANAGEMENT


	func createInitialRecords() {

		deleteAllEvents()

		let r1 = Result(action: .added, title: "Rug · Passaporto", date: dateAndTimeFormatter.date(from: "23-6-2025 8:00")!, allday: true, repeatType: 0, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 4, notifyQuantity: 2, notifyMode: 0)
		let r2 = Result(action: .added, title: "Bianca · Compleanno", date: dateAndTimeFormatter.date(from: "4-2-1996 21:30")!, allday: true, repeatType: 6, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 0, notifyQuantity: 0, notifyMode: 0)
		let r3 = Result(action: .added, title: "Clara · Compleanno", date: dateAndTimeFormatter.date(from: "25-7-1962 0:00")!, allday: true, repeatType: 6, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 0, notifyQuantity: 0, notifyMode: 0)
		let r4 = Result(action: .added, title: "Pietro · Compleanno", date: dateAndTimeFormatter.date(from: "8-1-1999 8:00")!, allday: true, repeatType: 6, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 0, notifyQuantity: 0, notifyMode: 0)
		let r5 = Result(action: .added, title: "EZ Birthday", date: dateAndTimeFormatter.date(from: "21-11-2010 8:00")!, allday: true, repeatType: 6, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 0, notifyQuantity: 0, notifyMode: 0)
		let r6 = Result(action: .added, title: "Rug · Patente", date: dateAndTimeFormatter.date(from: "13-12-2020 9:00")!, allday: true, repeatType: 0, repeatQuantity: 0, endRepeatType: 0, endRepeatQuantity: 0, notifyType: 4, notifyQuantity: 2, notifyMode: 0)
		let r7 = Result(action: .added, title: "Evento con titolo molto lungo", date: Date())


		saveEventWithStruct(eventToSave: nil, res: r1)
		saveEventWithStruct(eventToSave: nil, res: r2)
		saveEventWithStruct(eventToSave: nil, res: r3)
		saveEventWithStruct(eventToSave: nil, res: r4)
		saveEventWithStruct(eventToSave: nil, res: r5)
		saveEventWithStruct(eventToSave: nil, res: r6)
		saveEventWithStruct(eventToSave: nil, res: r7)

		let faker = Faker()
		for _ in 1...15 {
			let r = Result(action: .added, title: faker.team.name() , date: Date.random())
			saveEventWithStruct(eventToSave: nil, res: r)
		}


	}
	

	func saveEventWithStruct(eventToSave: Event?, res: Result) {

		let event: Event = eventToSave != nil ? eventToSave! : Event(context: managedObjectContext!)
		let date: Date =  res.date

		event.title = res.title
		event.date = date as NSDate

		event.rolledDate = rollDate(startDate: date, repeatType: Every(rawValue: res.repeatType)!, repeatQuantity: res.repeatQuantity, endRepeatType: res.endRepeatType, endRepeatQuantity: res.endRepeatQuantity)  as NSDate?

		event.allday = true
		event.repeatType = Int32(res.repeatType)
		event.repeatQuantity = Int32(res.repeatQuantity)
		event.endRepeatType = Int32(res.endRepeatType)
		event.endRepeatQuantity = Int32(res.endRepeatQuantity)
		event.notifyType = Int32(res.notifyType)
		event.notifyQuantity = Int32(res.notifyQuantity)
		event.notifyMode = Int32(res.notifyMode)

		do {
			try managedObjectContext!.save()
		} catch { fatalError("Error in storing data") }

	}


	func deleteAllEvents() {

		let request: NSFetchRequest<Event> = Event.fetchRequest()
		let batchDeleteRequest: NSBatchDeleteRequest

		do {
			batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
			try context.execute(batchDeleteRequest)
		} catch {
			fatalError("Failed removing existing records")
		}
	}


	func loadEvents() {

		let request: NSFetchRequest<Event> = Event.fetchRequest()

		do {
			let results = try managedObjectContext?.fetch(request)
			events = (results?.sorted(by: { ($0.rolledDate as! Date) < ($1.rolledDate as! Date) }))!
		} catch {
			fatalError("Error in retrieving items")
		}
	}

	func displayEvent(event: Event) {

		if let title = event.title { debugPrint(title, terminator: " - ") }
		if let date = event.date { debugPrint(dateFormatter.string(from: date as Date), terminator: " - ") }
		if let rDate = event.rolledDate { debugPrint(dateFormatter.string(from: rDate as Date), terminator: " - ") }

		debugPrint("Every: \(event.every)", terminator: " - ")
		debugPrint("\(event.allday)", terminator: " - ")
		debugPrint(event.repeatType, terminator: " - ")
		debugPrint(event.repeatQuantity, terminator: " \n ")
	}



	// MARK: - SEGUE

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == "addOrEditSegue" {

			let navigationController = segue.destination as! UINavigationController
			let destinationController = navigationController.topViewController as! AddOrEditController

			if sender is UITableViewCell {
				let row = (self.tableView.indexPath(for: sender as! UITableViewCell)?.row)!
				destinationController.addOrEditEvent = events[row]
			} else {
				destinationController.addOrEditEvent = nil
			}
		}
	}

	@IBAction func unwindToMainController(segue: UIStoryboardSegue) {

		let navigationController = segue.source as! AddOrEditController
		guard let res = navigationController.theResult else { return }
		
//		print(res)

		switch res.action {

		case .canceled:
			break

		case .added:
			saveEventWithStruct(eventToSave: nil, res: res)
			
		case .edited:
			saveEventWithStruct(eventToSave: navigationController.addOrEditEvent, res: res)
		}

		loadEvents()
		eventsTable.reloadData()
	}

	@IBAction func unwindToMainControllerFromPreferences(segue: UIStoryboardSegue) {

		loadPreferences()
		eventsTable.reloadData()
	}

	// MARK: - BADGE NOTIFICATION

	func badgeNotification(badgeCount: Int) {

		let application = UIApplication.shared
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
			// Enable or disable features based on authorization.
			print(granted)
		}
		application.applicationIconBadgeNumber = badgeCount
	}

	// MArk: - LOAD PREFERENCES

	func loadPreferences() {

//		var colloquialIsOn: Bool = false
//		var normalColor: UIColor = .black
//		var attentionColor: UIColor = .orange
//		var alarmColor: UIColor = .red
//		var titleFontSize: Int = 20
//		var detailFontSize: Int = 13

//		let colloquialKey = "colloquial"
//		let normalColorKey = "normalColor"
//		let attentioncolorKey = "attentionColor"
//		let alertColorKey = "alertColor"
//		let titleFontSizeKey = "titleFontSize"
//		let detailFontSizeKey = "detailFontSize"

		let defaults = UserDefaults.standard

		colloquialIsOn = defaults.bool(forKey: PrefsKey.colloquialKey.rawValue)
		animateTableIsOn = defaults.bool(forKey: PrefsKey.animateTableIsOnKey.rawValue)

		titleFontSize = defaults.float(forKey: PrefsKey.titleFontSizeKey.rawValue)
		if titleFontSize == 0.0 { titleFontSize = 20.0 }

		detailFontSize = defaults.float(forKey: PrefsKey.detailFontSizeKey.rawValue)
		if detailFontSize == 0.0 { detailFontSize = 13.0 }
	}

	// MARK: - TABLE ANIMATION

	override func viewWillAppear(_ animated: Bool) {

		if animateTableIsOn { animateTable() }
	}

	func animateTable() {

		eventsTable.reloadData()

		let cells = eventsTable.visibleCells
		let tableHeight: CGFloat = eventsTable.bounds.size.height

		for i in cells {
			let cell: UITableViewCell = i as UITableViewCell
			cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
		}

		var index = 0

		for a in cells {
			let cell: UITableViewCell = a as UITableViewCell

			UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn , animations: {
				cell.transform = CGAffineTransform(translationX: 0, y: 0);
			}, completion: nil)

			index += 1
		}
	}

	func handleRefresh(refreshControl: UIRefreshControl) {

		colloquialIsOn.toggle()
		let defaults = UserDefaults.standard
		defaults.set(colloquialIsOn, forKey: PrefsKey.colloquialKey.rawValue)

		self.eventsTable.reloadData()
		refreshControl.endRefreshing()
	}
}
