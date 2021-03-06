//
//  MainController.swift
//  D11
//
//  Created by Ruggero Civitarese on 18/01/17.
//  Copyright © 2017 Ruggero Civitarese. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

import SwiftDate
import Fakery
import MGSwipeTableCell


class EventCell: MGSwipeTableCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detail1Label: UILabel!
}



class MainController: UITableViewController, MGSwipeTableCellDelegate {

	@IBOutlet var eventsTable: UITableView!

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var managedObjectContext: NSManagedObjectContext?

	var badgeCount: Int = 0
	var events = [Event]()
	var sortEventsBy: SortEventsBy = SortEventsBy.date


	var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}



	// MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

//		Working directory of the simulator
//		let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//		print("Simulator working direcotry: \(dirPaths[0])")



		// Removes empty lines in the table
		eventsTable.tableFooterView = UIView()

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		managedObjectContext = appDelegate.persistentContainer.viewContext

		UNUserNotificationCenter.current().delegate = self
		
		self.refreshControl?.addTarget(self, action: #selector(MainController.handleRefresh) , for: UIControlEvents.valueChanged)

//		createInitialRecords()
//		deleteAllEvents()

		initializePreferences()
		loadPreferences()
		loadEvents()
		resetEventsNotifications()
    }

	// ^^^^^^ END VIEWDIDLOAD ^^^^^^




    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	// MARK: - TABLE VIEW DATA SOURCE

	override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return events.count }



	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellIdentifier", for: indexPath) as! EventCell

		cell.delegate = self

//		let today = Date()
		let ev = events[indexPath.row]

		guard
			let tit   = ev.value(forKey: "title") as? String,
			let dt1   = ev.value(forKey: "date") as? Date,
			let evrN  = ev.value(forKey: "repeatType") as? Int,
			let evrQN = ev.value(forKey: "repeatQuantity") as? Int,
			let ert   = ev.value(forKey: "endRepeatType") as? Int,
			let erq   = ev.value(forKey: "endRepeatQuantity") as? Int,
			let nt    = ev.value(forKey: "notifyType") as? Int,
			let nq    = ev.value(forKey: "notifyQuantity") as? Int,
			let nm    = ev.value(forKey: "notifyMode") as? Int
			else {
				print("Type error")
				return cell
		}


		let evr = Every(rawValue: evrN)!

		let (newDate, colloquial) = dateDistanceFromNow(toDate: dt1, repeatType: evr, repeatQuantity: evrQN, endRepeatType: ert, endRepeatQuantity: erq)

		cell.titleLabel.text = tit // + (nt == 0 ? "" : "⊙") // SIMBOLO CAMPANELLA SE NOTIFICA ATTIVA
		cell.detail1Label.text = colloquialIsOn ? colloquial : dateAndTimeFormatter.string(from: newDate)
		if nt != 0 { cell.detail1Label.text = "· " + (cell.detail1Label.text ?? " – ") }

		let font = cell.titleLabel.font.fontName
		let size = NSNumber(value: Double(titleFontSize))
		cell.titleLabel.font = UIFont(name: font, size: CGFloat(size))

		let font1 = cell.detail1Label.font.fontName
		let size1 = NSNumber(value: Double(detailFontSize))
		cell.detail1Label.font = UIFont(name: font1, size: CGFloat(size1))

		let notificationDate = getNotificationDate(date: newDate, notifyType: nt, notifyQuantity: nq, notifyMode: nm)
		cell.detail1Label.textColor = getTextLabelColor(notifyMode: nm, notificationDate: notificationDate, eventDate: newDate)


		// configure swipe left buttons
		// green: 03B100
		let cellButton1 = MGSwipeButton(title: "", icon: UIImage(named: "fat-pencil-90.png"), backgroundColor: UIColor.editSwipeBackground , padding: 30, callback: { (cell) -> Bool in

			self.editCell(cell: cell)
			return true
		})
		let cellButton2 = MGSwipeButton(title: "", icon: UIImage(named: "information-symbol.png"), backgroundColor: UIColor.orange , padding: 20, callback: { (cell) -> Bool in

			self.showCellInfo(cell: cell)
			return true
		})

		cell.leftButtons = [cellButton1, cellButton2]
		cell.leftSwipeSettings.transition = MGSwipeTransition.static
		cell.leftExpansion.buttonIndex = 0
		cell.leftExpansion.fillOnTrigger = true
		cell.leftExpansion.threshold = 1.3

		
		//configure swipe right buttons
		let rightButton1 = MGSwipeButton(title: "", icon: UIImage(named:"cross.png"), backgroundColor: UIColor.red, padding: 30, callback: {
			(cell) -> Bool in

			self.deleteCell(cell: cell)
			return true
		})
		cell.rightButtons = [rightButton1]
		cell.rightSwipeSettings.transition = MGSwipeTransition.static
		cell.rightExpansion.buttonIndex = 0
		cell.rightExpansion.fillOnTrigger = true
		cell.rightExpansion.threshold = 1.3

		return cell
	}


	// MARK: - SWIPE HELPER METHODS

	func showCellInfo(cell: UITableViewCell) {

		let row = (self.tableView.indexPath(for: cell)?.row)!
		let event = events[row]

		let title = event.title ?? "Title"
		let date = dateAndTimeFormatter.string(from: event.date! as Date) // !!!!!!
		let allday = "\(event.allday)"
		let rDate = dateAndTimeFormatter.string(from: event.rolledDate! as Date) // !!!!!
		let rep = repeatTextForRepeatLabel(repeatType: Int(event.repeatType), repeatQuantity: Int(event.repeatQuantity) - 1)
		let endRep = endRepeatTextForEndRepeatLabel(endRepeatType: Int(event.endRepeatType), endRepeatQuantity: Int(event.endRepeatQuantity) - 1)
		let notify = notifyTextForNotifyLabel(notifyType: Int(event.notifyType), notifyQuantity: Int(event.notifyQuantity) - 1, notifyMode: Int(event.notifyMode))

		var notDate = "none"
		if let ndate = event.notificationDate {
			if Int(event.notifyType) != 0 {
				notDate = dateAndTimeFormatter.string(from: ndate as Date)
			}
		}

//		let notId = "Notification id: \(event.notificationId ?? "none")"

		var body = "All-day event: \(allday)\n"
		body += "Date: \(date)\n"
		body += "Repeat: \(rep)\n"
		body += "End repeat: \(endRep)\n"
		body += "Rolled date: \(rDate)\n"
		body += "Notify: \(notify)\n"
		body += "Notification date: \(notDate)\n"

		let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

	func deleteCell(cell: UITableViewCell) {

		tableView.beginUpdates()

		do {
			let row = (self.tableView.indexPath(for: cell)?.row)!
			context.delete(events[row])
			try context.save()
			loadEvents()
			debugPrint("Deleting cell number \(row)")
		} catch let error { debugPrint("3·\(error)") }

		tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .fade)
		tableView.endUpdates()
	}

	func editCell(cell: UITableViewCell) {

		tableView.beginUpdates()
		performSegue(withIdentifier: "addOrEditSegue", sender: cell)
		tableView.endUpdates()
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

		var notificationDate     = date
		let notificationQuantity = notifyQuantity + 1
		let notificationType     = Every(rawValue: notifyType)!
		let notificationMode     = Mode(rawValue: notifyMode)!

		var quantity = 1.minute

		switch(notificationType) {
		case Every.never: break
		case Every.minute: quantity  = notificationQuantity.minute
		case Every.hour: quantity    = notificationQuantity.hour
		case Every.day: quantity     = notificationQuantity.day
		case Every.week: quantity    = notificationQuantity.week
		case Every.month: quantity   = notificationQuantity.month
		case Every.quarter: quantity = (notificationQuantity * 3).month
		case Every.year: quantity    = notificationQuantity.year
		}

		switch(notificationMode) {
		case Mode.before: notificationDate = notificationDate - quantity
		case Mode.after: notificationDate = notificationDate + quantity
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

		var newDate    = startDate
		let rquantity  = repeatQuantity
		let erquantity = endRepeatType == 0 ? 0 : endRepeatQuantity

		var countRepetitions = endRepeatType == 0 ? 0 : 1

		if newDate.isInPast && repeatType != Every.never {

			while newDate.isBefore(date: Date(), granularity: .second) && countRepetitions <= erquantity {
				countRepetitions += endRepeatType == 0 ? 0 : 1
				switch(repeatType) {
				case Every.never: break
				case Every.minute: newDate  = newDate + rquantity.minute
				case Every.hour: newDate    = newDate + rquantity.hour
				case Every.day: newDate     = newDate + rquantity.day
				case Every.week: newDate    = newDate + rquantity.week
				case Every.month: newDate   = newDate + rquantity.month
				case Every.quarter: newDate = newDate + (rquantity * 3).month
				case Every.year: newDate    = newDate + rquantity.year
				}
			}
		}
		return newDate
	}


	// MARK: - CORE DATA MANAGEMENT

	func createInitialRecords() {

		deleteAllEvents()

		let r1 = Result(action: .added, title: "Rxx · Passaporto", date: dateAndTimeFormatter.date(from: "23-6-2025 8:00")!)
		let r2 = Result(action: .added, title: "Bkkkkk · Compleanno", date: dateAndTimeFormatter.date(from: "4-2-1996 21:30")!)
		let r3 = Result(action: .added, title: "Cjjjj · Compleanno", date: dateAndTimeFormatter.date(from: "25-7-1962 0:00")!)
		let r4 = Result(action: .added, title: "Pdddd · Compleanno", date: dateAndTimeFormatter.date(from: "8-1-1999 8:00")!)
		let r5 = Result(action: .added, title: "Ek Birthday", date: dateAndTimeFormatter.date(from: "21-11-2010 8:00")!)
		let r6 = Result(action: .added, title: "Rxx · Patente", date: dateAndTimeFormatter.date(from: "13-12-2020 9:00")!)
		let r7 = Result(action: .added, title: "Evento con titolo molto lungo", date: Date())


		saveEventWithStruct(eventToSave: nil, res: r1)
		saveEventWithStruct(eventToSave: nil, res: r2)
		saveEventWithStruct(eventToSave: nil, res: r3)
		saveEventWithStruct(eventToSave: nil, res: r4)
		saveEventWithStruct(eventToSave: nil, res: r5)
		saveEventWithStruct(eventToSave: nil, res: r6)
		saveEventWithStruct(eventToSave: nil, res: r7)

		let faker = Faker()
		for _ in 1...3 {
			let r = Result(action: .added, title: faker.team.name() , date: Date.random())
			saveEventWithStruct(eventToSave: nil, res: r)
		}


	}
	

	public func saveEventWithStruct(eventToSave: Event?, res: Result) {

		let event: Event = eventToSave != nil ? eventToSave! : Event(context: managedObjectContext!)
		let date: Date   = res.allday ? setAlldayEventToPrefTime(date: res.date) : res.date

		event.title = res.title
		event.date = date as NSDate

		event.rolledDate = rollDate(startDate: date, repeatType: Every(rawValue: res.repeatType)!, repeatQuantity: res.repeatQuantity, endRepeatType: res.endRepeatType, endRepeatQuantity: res.endRepeatQuantity)  as NSDate?

		notificationIdCounter += 1
		UserDefaults.standard.setValue (notificationIdCounter, forKey: PrefsKey.notificationIdCounterKey.rawValue)

		event.allday            = res.allday
		event.repeatType        = Int32(res.repeatType)
		event.repeatQuantity    = Int32(res.repeatQuantity)
		event.endRepeatType     = Int32(res.endRepeatType)
		event.endRepeatQuantity = Int32(res.endRepeatQuantity)
		event.notifyType        = Int32(res.notifyType)
		event.notifyQuantity    = Int32(res.notifyQuantity)
		event.notifyMode        = Int32(res.notifyMode)
		event.notificationId    = "thedate.notification.\(notificationIdCounter)"
		event.notificationDate  = calculateNotificationDate(event: event) as NSDate

		do {
			try managedObjectContext!.save()
		} catch { fatalError("Error in storing data") }

		// Check for User Notifications Settings
//		let grantedNotificatiosSettings = UIApplication.shared.currentUserNotificationSettings
//		print(grantedNotificatiosSettings ?? "No granted notification settings found")

//		sendNotification(event: event)
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

			switch sortEventsBy {
			case .date: events  = (results?.sorted(by: { ($0.rolledDate! as Date) < ($1.rolledDate! as Date) }))!
			case .title: events = (results?.sorted(by: { $0.title! < $1.title!  }))!
			}
		} catch {
			fatalError("Error in retrieving items")
		}
	}

	func resetEventsNotifications() {

		let center = UNUserNotificationCenter.current()
		center.removeAllDeliveredNotifications()
		center.removeAllPendingNotificationRequests()

		for event in events {
			sendNotification(event: event)
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
		
		switch res.action {
		case .canceled: break
		case .added:    saveEventWithStruct(eventToSave: nil, res: res)
		case .edited:   saveEventWithStruct(eventToSave: navigationController.addOrEditEvent, res: res)
		}

		loadEvents()
		resetEventsNotifications()
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

	// MARK: - LOAD PREFERENCES

	func initializePreferences() {

		UserDefaults.standard.register(defaults: [
			PrefsKey.colloquialKey.rawValue: true,
			PrefsKey.animateTableIsOnKey.rawValue: true,
			PrefsKey.titleFontSizeKey.rawValue: 20.0,
			PrefsKey.detailFontSizeKey.rawValue: 13.0,
			PrefsKey.sortEventsByKey.rawValue: SortEventsBy.date.rawValue,
			PrefsKey.notificationIdCounterKey.rawValue: 1,
			PrefsKey.alldayNotificationMinuteKey.rawValue: 9 * 60
			])
	}

	func loadPreferences() {

		let defaults = UserDefaults.standard

		colloquialIsOn = defaults.bool(forKey: PrefsKey.colloquialKey.rawValue)
		animateTableIsOn = defaults.bool(forKey: PrefsKey.animateTableIsOnKey.rawValue)

		titleFontSize = defaults.float(forKey: PrefsKey.titleFontSizeKey.rawValue)
		if titleFontSize == 0.0 { titleFontSize = 20.0 }

		detailFontSize = defaults.float(forKey: PrefsKey.detailFontSizeKey.rawValue)
		if detailFontSize == 0.0 { detailFontSize = 13.0 }

		if let sortType = SortEventsBy(rawValue: defaults.integer(forKey: PrefsKey.sortEventsByKey.rawValue)) {
			sortEventsBy = sortType
		} else {
			sortEventsBy = SortEventsBy.date
		}

		notificationIdCounter = defaults.integer(forKey: PrefsKey.notificationIdCounterKey.rawValue)
		alldayNotificationMinute = defaults.integer(forKey: PrefsKey.alldayNotificationMinuteKey.rawValue)
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

	// MARK: - PULL TO REFRESH

	func handleRefresh(refreshControl: UIRefreshControl) {

//		colloquialIsOn.toggle()
		let defaults = UserDefaults.standard
		defaults.set(colloquialIsOn, forKey: PrefsKey.colloquialKey.rawValue)

		self.eventsTable.reloadData()
//		animateTable()
		refreshControl.endRefreshing()
	}

	// MARK: - TOOLBAR

	@IBAction func sortToolbarButtonPushed(_ sender: Any) {
		
		switch sortEventsBy {
		case .date:
			sortEventsBy = SortEventsBy.title
		case .title:
			sortEventsBy = SortEventsBy.date
		}
		
		let defaults = UserDefaults.standard
		defaults.set(SortEventsBy.date.rawValue, forKey: PrefsKey.sortEventsByKey.rawValue)

		self.loadEvents()
		self.animateTable()
	}

	@IBAction func calendarToolbarButtonPushed(_ sender: Any) {

		colloquialIsOn.toggle()
		let defaults = UserDefaults.standard
		defaults.set(colloquialIsOn, forKey: PrefsKey.colloquialKey.rawValue)

		self.animateTable()
	}
}
