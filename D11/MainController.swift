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


class EventCell: SwipeCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detail1Label: UILabel!
	@IBOutlet weak var detail2Label: UILabel!
}




class MainController: UITableViewController {

	@IBOutlet var eventsTable: UITableView!

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	var events = [Event]()
	var managedObjectContext: NSManagedObjectContext?


	var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}


    override func viewDidLoad() {
        super.viewDidLoad()

		// Removes empty lines in the table
		eventsTable.tableFooterView = UIView()

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		managedObjectContext = appDelegate.persistentContainer.viewContext

		createInitialRecords()

		loadEvents()
		

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return events.count }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellIdentifier", for: indexPath)  as! EventCell

		cell.swipeDelegate = self

		let ev = events[indexPath.row]

		guard let tit = ev.value(forKey: "title") as? String else { print("Title error"); return cell }
		guard let dt1 = ev.value(forKey: "date") as? Date else { print("Date error"); return cell }
		guard let evrN = ev.value(forKey: "every") as? Int else { print("Every error"); return cell }
		let evr = Every(rawValue: evrN)!

		let (newDate, colloquial) = dateDistanceFromNow(toDate: dt1, repeatTime: evr)

		cell.titleLabel.text = tit
		cell.detail1Label.text = dt1.string(format: .custom("dd-M-yyyy")) + "(r\(evrN))"
		cell.detail2Label.text = colloquial

		if newDate < Date() { cell.detail2Label.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) }



		// SWIPE RIGHT1 TO DELETE
		cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.right1, swipeMode: SwipeCell.SwipeMode.slide, icon: UIImageView(image: UIImage(named: "cross")), color: .red) { (cell) -> () in
			self.deleteCell(cell: cell)
		}

		//		cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.right2, swipeMode: SwipeCell.SwipeMode.bounce, icon: UIImageView(image: UIImage(named: "list")), color: .blue) { (cell) -> () in
		//			self.deleteCell(cell: cell)
		//		}
		//		cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.right3, swipeMode: SwipeCell.SwipeMode.slide, icon: UIImageView(image: UIImage(named: "clock")), color: .orange) { (cell) -> () in
		//			self.deleteCell(cell: cell)
		//		}
		//		cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.right4, swipeMode: SwipeCell.SwipeMode.slide, icon: UIImageView(image: UIImage(named: "check")), color: .green) { (cell) -> () in
		//			self.deleteCell(cell: cell)
		//		}


		// SWIPE LEFT TO EDIT
		cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.left1, swipeMode: SwipeCell.SwipeMode.slide, icon: UIImageView(image: UIImage(named: "pencil")), color: .purple) { (cell) -> () in
			self.editCell(cell: cell)
		}



		return cell
	}




	// MARK: - DATE MANAGEMENT

	func rollDate(startDate: Date, repeatTime: Every) -> Date {

		var newDate = startDate

		if newDate.isInPast && repeatTime != Every.never {
			while newDate.isBefore(date: Date(), granularity: .day) {

				switch(repeatTime) {
				case Every.never:
					break
				case Every.day:
					newDate = newDate + 1.day
				case Every.week:
					newDate = newDate + 1.week
				case Every.month:
					newDate = newDate + 1.month
				case Every.year:
					newDate = newDate + 1.year
				}
			}
		}
		return newDate
	}


	func dateDistanceFromNow(toDate: Date, repeatTime: Every) -> (Date, String) {

		let newDate = rollDate(startDate: toDate, repeatTime: repeatTime)
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


	// MARK: - CORE DATA MANAGEMENT

	func createInitialRecords() {

		deleteAllEvents()

		let r1 = Result(action: .added, title: "Passaporto Ruggero", date: "23-6-2025", allday: true, repeatition: false, every: .never)
		let r2 = Result(action: .added, title: "Compleanno Bianca", date: "4-2-1996", allday: true, repeatition: false, every: .year)
		let r3 = Result(action: .added, title: "Compleanno Clara", date: "25-7-1962", allday: true, repeatition: false, every: .year)
		let r4 = Result(action: .added, title: "Compleanno Pietro", date: "8-1-1999", allday: true, repeatition: false, every: .year)
		let r5 = Result(action: .added, title: "EZ Birthday", date: "29-11-2010", allday: true, repeatition: false, every: .year)
		let r6 = Result(action: .added, title: "Testo molto più lungo di un reminder", date: "17-1-2017", allday: true, repeatition: false, every: .never)
		let r7 = Result(action: .added, title: "Pippo", date: "12-12-2018", allday: true, repeatition: false, every: Every.never)


		saveEventWithStruct(eventToSave: nil, res: r1)
		saveEventWithStruct(eventToSave: nil, res: r2)
		saveEventWithStruct(eventToSave: nil, res: r3)
		saveEventWithStruct(eventToSave: nil, res: r4)
		saveEventWithStruct(eventToSave: nil, res: r5)
		saveEventWithStruct(eventToSave: nil, res: r6)
		saveEventWithStruct(eventToSave: nil, res: r7)

	}

	func saveEventWithStruct(eventToSave: Event?, res: Result) {

		let event: Event = eventToSave != nil ? eventToSave! : Event(context: managedObjectContext!)
		let date: Date =  res.allday ? dateOnlyFormatter.date(from: res.date)! : dateAndTimeFormatter.date(from: res.date)!

		event.title = res.title
		event.date = date as NSDate
		event.rolledDate = rollDate(startDate: date, repeatTime: res.every) as NSDate?
		event.every = Int32(res.every.rawValue)
		event.allday = true
		event.repeatition = false

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
		debugPrint(event.repeatition, terminator: " \n ")
	}


	// MARK: - SWIPE OPTIONAL DELEGATE METHODS

	override func swipeTableViewCellDidStartSwiping(cell: UITableViewCell) {}
	override func swipeTableViewCellDidEndSwiping(cell: UITableViewCell) {}
	override func swipeTableViewCell(cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {}


	// MARK: - SWIPE HELPER METHODS

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

	// MARK: - SEGUE

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == "addOrEditSegue" {

			debugPrint("Preparing to leave the main controller")
	
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

		case .canceled:
			debugPrint("User canceled")
			break

		case .added:
			debugPrint("User added")
			print(res)
			saveEventWithStruct(eventToSave: nil, res: res)
			
		case .edited:
			debugPrint("User edited")
			saveEventWithStruct(eventToSave: navigationController.addOrEditEvent, res: res)
		}

		loadEvents()
		eventsTable.reloadData()
	}

}
