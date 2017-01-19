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

	var events = [NSManagedObject]()
	var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

		// Removes empty lines in the table
		eventsTable.tableFooterView = UIView()


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


	/*
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the specified item to be editable.
	return true
	}
	*/

	/*
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
	if editingStyle == .delete {
	// Delete the row from the data source
	tableView.deleteRows(at: [indexPath], with: .fade)
	} else if editingStyle == .insert {
	// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
	}
	*/

	/*
	// Override to support rearranging the table view.
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

	}
	*/

	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the item to be re-orderable.
	return true
	}
	*/



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

		saveEvent(title: "Passaporto Ruggero", date: dateFormatter.date(from: "2025-6-23")!, every: Every.never)
		saveEvent(title: "Patente Ruggero", date: dateFormatter.date(from: "2020-12-13")!, every: Every.never)
		saveEvent(title: "Compleanno Bianca", date: dateFormatter.date(from: "1996-2-4")!, every: Every.year)
		saveEvent(title: "Compleanno Clara", date: dateFormatter.date(from: "2017-7-25")!, every: Every.year)
		saveEvent(title: "Compleanno Pietro", date: dateFormatter.date(from: "1999-1-8")!, every: Every.year)
		saveEvent(title: "EZ Birthday", date: dateFormatter.date(from: "2010-11-29")!, every: Every.year)

		saveEvent(title: "Testo molto più lungo di un reminder", date: dateFormatter.date(from: "2017-1-17")!, every: Every.never)
	}

	func saveEvent(title: String, date: Date, every: Every) {

		let loc = NSEntityDescription.insertNewObject(forEntityName: "Events", into: context)
		loc.setValue(title, forKey: "title")
		loc.setValue(date, forKey: "date")
		loc.setValue(rollDate(startDate: date, repeatTime: every), forKey: "rolledDate")
		loc.setValue(every.rawValue, forKey: "every")

		loc.setValue(true, forKey: "allday")
		loc.setValue(false, forKey: "repeatition")

		do {
			try context.save()
			debugPrint("Record (\(title) - \(dateFormatter.string(from: date)))) Saved")
		} catch let error {
			debugPrint("1·\(error)")
		}
	}


	func saveEventWithStruct(res: Result) {

		var date = Date()

		if res.allday {
			date = dateOnlyFormatter.date(from: res.date)!
		} else {
			date = dateAndTimeFormatter.date(from: res.date)!
		}


		let loc = NSEntityDescription.insertNewObject(forEntityName: "Events", into: context)
		loc.setValue(res.title, forKey: "title")
		
		loc.setValue(date, forKey: "date")

		loc.setValue(rollDate(startDate: date, repeatTime: res.every), forKey: "rolledDate")
		loc.setValue(res.every.rawValue, forKey: "every")


		loc.setValue(true, forKey: "allday")
		loc.setValue(false, forKey: "repeatition")

		do {
			try context.save()
			debugPrint("Record (\(title) - \(dateFormatter.string(from: date)))) Saved")
		} catch let error {
			debugPrint("1·\(error)")
		}



	}


	func deleteAllEvents() {

		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
		request.returnsObjectsAsFaults = false
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)

		do {
			try context.execute(batchDeleteRequest)
		} catch let error {
			debugPrint(error)
		}
	}

	func loadEvents() {

		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
		request.returnsObjectsAsFaults = false

		events.removeAll()

		do {
			let evs = try context.fetch(request)
			if evs.count > 0 {
				for ev in evs as! [NSManagedObject] {

					events.append(ev)
					displayEvent(event: ev)
				}

				// SORT BY REVERESE DATE
				events.sort(by: { (($0.value(forKey: "rolledDate")) as! Date) < (($1.value(forKey: "rolledDate")) as! Date) })

				debugPrint("\(evs.count) records loaded .")
			} else { debugPrint("No results") }
		} catch let error { debugPrint("2·\(error)") }
	}

	func displayEvent(event: NSManagedObject) {

		if let title = event.value(forKey: "title") { debugPrint(title, terminator: " - ") }
		if let date = event.value(forKey: "date") { debugPrint(dateFormatter.string(from: date as! Date), terminator: " - ") }
		if let rDate = event.value(forKey: "rolledDate") { debugPrint(dateFormatter.string(from: rDate as! Date), terminator: " - ") }
		if let every = event.value(forKey: "every") { debugPrint("Every: \(Every(rawValue: every as! Int)!)", terminator: " - ") }
		if let allDay = event.value(forKey: "allday") { debugPrint(allDay, terminator: " - ") }
		if let rep = event.value(forKey: "repeatition") { debugPrint(rep, terminator: " \n ") }

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

		//		let row = (self.tableView.indexPath(for: cell)?.row)!
		//		debugPrint("Editing cell number \(row)")

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

		debugPrint("Returned to MainController")

		let navigationController = segue.source as! AddOrEditController

		guard let res = navigationController.theResult else { return }
		let actionTaken = res.action

		switch actionTaken {

		case .canceled:
			debugPrint("User canceled")

		case .added:
			debugPrint("User added")
			saveEventWithStruct(res: res)
			
		case .edited:
			debugPrint("User edited")
		}

		print(res)
		loadEvents()
		eventsTable.reloadData()
	}

}
