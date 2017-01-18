//
//  SwipeTableViewCell.swift
//  swipe
//
//  Created by Ethan Neff on 3/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

// delegate for the child
protocol SwipeDelegate: class {
	func swipeTableViewCellDidStartSwiping(cell: UITableViewCell)

	func swipeTableViewCellDidEndSwiping(cell: UITableViewCell)

	func swipeTableViewCell(cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat)
}

// make the parent controller conform to the delegate (able to listen)
extension UITableViewController: SwipeDelegate {
	func swipeTableViewCellDidStartSwiping(cell: UITableViewCell) {}

	func swipeTableViewCellDidEndSwiping(cell: UITableViewCell) {}

	func swipeTableViewCell(cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {}
}

class SwipeCell: UITableViewCell {
	// MARK: - PROPERTIES
	// constants
	let kDurationLowLimit: TimeInterval = 0.25;
	let kDurationHighLimit: TimeInterval = 0.1;
	let kVelocity: CGFloat = 0.7
	let kDamping: CGFloat = 0.5
	// public properties
	weak var swipeDelegate: SwipeDelegate?
	var shouldDrag = true
	var shouldAnimateIcons = true
	var firstTrigger: CGFloat = 0.15
	var secondTrigger: CGFloat = 0.35
	var thirdTrigger: CGFloat = 0.55
	var forthTrigger: CGFloat = 0.75
	var defaultColor: UIColor = .lightGray
	// private properties
	fileprivate var dragging = false
	fileprivate var isExiting = false
	fileprivate var contentScreenshotView = UIImageView()
	fileprivate var colorIndicatorView = UIView()
	fileprivate var iconView = UIView()
	fileprivate var direction: SwipeDirection = .center
	fileprivate var swipe: UIPanGestureRecognizer?

	fileprivate var Left1: SwipeObject?
	fileprivate var Left2: SwipeObject?
	fileprivate var Left3: SwipeObject?
	fileprivate var Left4: SwipeObject?
	fileprivate var Right1: SwipeObject?
	fileprivate var Right2: SwipeObject?
	fileprivate var Right3: SwipeObject?
	fileprivate var Right4: SwipeObject?

	typealias SwipeCompletion = (_ cell: UITableViewCell) -> ()

	enum SwipeDirection {
		case center
		case left
		case right
	}

	enum SwipeGesture {
		case left1
		case left2
		case left3
		case left4
		case right1
		case right2
		case right3
		case right4
	}

	enum SwipeMode {
		case bounce
		case slide
	}

	fileprivate struct SwipeObject {
		// the swipe gesture object per cell
		var color: UIColor
		var icon: UIView
		var mode: SwipeMode
		var completion: SwipeCompletion

		init(color: UIColor, mode: SwipeMode, icon: UIView, completion: @escaping SwipeCompletion) {
			self.color = color
			self.mode = mode
			self.icon = icon
			self.completion = completion
		}
	}

	//   MARK: - INIT
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initializer()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializer()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		swipeDealloc()
		initializer()
	}

	fileprivate func initializer() {
		// layout
		selectionStyle = .none
		separatorInset = UIEdgeInsets.zero
		layoutMargins = UIEdgeInsets.zero

		// swipe gesture
		swipe = UIPanGestureRecognizer(target: self, action:#selector(SwipeCell.handleSwipeGesture(_:)))
		if let swipe = swipe {
			swipe.delegate = self
			addGestureRecognizer(swipe)
		}
	}

	// MARK: - PUBLIC ADD SWIPE
	func addSwipeGesture(swipeGesture: SwipeGesture, swipeMode: SwipeMode, icon: UIImageView, color: UIColor, completion: @escaping SwipeCompletion) {
		// public function to add a new gesture on the cell
		switch swipeGesture {
		case .left1: Left1 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .left2: Left2 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .left3: Left3 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .left4: Left4 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .right1: Right1 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .right2: Right2 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .right3: Right3 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		case .right4: Right4 = SwipeObject(color: color, mode: swipeMode, icon: icon, completion: completion)
		}
	}

	// MARK: - GESTURE RECOGNIZER
	func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {
		if !shouldDrag || isExiting {
			return
		}

		let state = gesture.state
		let translation = gesture.translation(in: self)
		let velocity = gesture.velocity(in: self)
		let percentage = swipeGetPercentage(offset: contentScreenshotView.frame.minX, width: self.bounds.width)
		let duration = swipeGetAnimationDuration(velocity: velocity)
		let direction = swipeGetDirection(percentage: percentage)

		if state == .began {
			// began
			dragging = true
			swipeDelegate?.swipeTableViewCellDidStartSwiping(cell: self)
			swipeCreateView(state: state)
		}
		if state == .began || state == .changed {
			// changed (moving)
			swipeDelegate?.swipeTableViewCell(cell: self, didSwipeWithPercentage: percentage)
			let center: CGPoint = CGPoint(x: contentScreenshotView.center.x + translation.x, y: contentScreenshotView.center.y)
			contentScreenshotView.center = center
			swipeAnimateHold(offset: contentScreenshotView.frame.minX, direction: direction)
			gesture.setTranslation(CGPoint.zero, in: self)
		} else if state == .cancelled || state == .ended {
			// ended or cancelled
			dragging = false
			isExiting = true
			swipeDelegate?.swipeTableViewCellDidEndSwiping(cell: self)
			let object = swipeGetObject(percentage: percentage)
			if let object = object {
				let icon = object.icon
				let completion = object.completion
				let mode = object.mode

				if swipeGetBeforeTrigger(percentage: percentage, direction: direction) ||  mode == .bounce {
					// bounce
					swipeDirectionBounce(duration: duration, direction: direction, icon: icon, completion: completion, percentage: percentage)
				} else {
					// slide
					swipeDirectionSlide(duration: duration, direction: direction, icon: icon, completion: completion)
				}
			} else {
				// bounce
				swipeDirectionBounce(duration: duration, direction: direction, icon: nil, completion: nil, percentage: percentage)
			}
		}
	}

	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		// needed to allow scrolling of the tableview
		if let g = gestureRecognizer as? UIPanGestureRecognizer {
			let point: CGPoint = g.velocity(in: self)
			// if moving x instead of y
			if fabs(point.x) > fabs(point.y) {
				// prevent swipe if there is no gesture in that direction
				if !swipeGetGestureDirection(direction: .left) && point.x < 0 {
					return false
				}
				if !swipeGetGestureDirection(direction: .right) && point.x > 0 {
					return false
				}
				return true
			}
		}
		return false
	}

	// MARK: - BEGIN
	fileprivate func swipeCreateView(state: UIGestureRecognizerState) {
		// get the image of the cell
		let contentViewScreenshotImage: UIImage = swipeScreenShot(self)

		colorIndicatorView = UIView(frame: bounds)
		colorIndicatorView.autoresizingMask = ([.flexibleHeight, .flexibleWidth])
		colorIndicatorView.backgroundColor = defaultColor
		addSubview(colorIndicatorView)

		iconView = UIView()
		iconView.contentMode = .center
		colorIndicatorView.addSubview(iconView)

		contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
		addSubview(contentScreenshotView)
	}

	fileprivate func swipeScreenShot(_ view: UIView) -> UIImage {
		// create a snapshot (copy) of the cell
		let scale: CGFloat = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
		view.layer.render(in: UIGraphicsGetCurrentContext()!)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return image
	}

	// MARK: - CHANGED
	fileprivate func swipeAnimateHold(offset: CGFloat, direction: SwipeDirection) {
		// move the cell when swipping
		let percentage = swipeGetPercentage(offset: offset, width: bounds.width)
		let object = swipeGetObject(percentage: percentage)
		if let object = object {
			// change to the correct icons and colors
			colorIndicatorView.backgroundColor = swipeGetBeforeTrigger(percentage: percentage, direction: direction) ? defaultColor : object.color
			swipeResetIcon(icon: object.icon)
			swipeUpdateIcon(percentage: percentage, direction: direction, icon: object.icon, isDragging: shouldAnimateIcons)
		} else {
			colorIndicatorView.backgroundColor = defaultColor
		}
	}

	fileprivate func swipeResetIcon(icon: UIView) {
		// remove the old icons when changing between sections
		let subviews = iconView.subviews
		for view in subviews {
			view.removeFromSuperview()
		}
		// add the new icon
		iconView.addSubview(icon)
	}

	fileprivate func swipeUpdateIcon(percentage: CGFloat, direction: SwipeDirection, icon: UIView, isDragging: Bool) {
		// position the icon when swiping
		var position: CGPoint = CGPoint.zero
		position.y = self.bounds.height / 2.0
		if isDragging {
			// near the cell
			if percentage >= 0 && percentage < firstTrigger {
				position.x = swipeGetOffset(percentage: (firstTrigger / 2), width: bounds.width)
			} else if percentage >= firstTrigger {
				position.x = swipeGetOffset(percentage: percentage - (firstTrigger / 2), width: bounds.width)
			} else if percentage < 0 && percentage >= -firstTrigger {
				position.x = bounds.width - swipeGetOffset(percentage: (firstTrigger / 2), width: bounds.width)
			} else if percentage < -firstTrigger {
				position.x = bounds.width + swipeGetOffset(percentage: percentage + (firstTrigger / 2), width: bounds.width)
			}
		} else {
			// float either left or right
			if direction == .right {
				position.x = swipeGetOffset(percentage: (firstTrigger / 2), width: self.bounds.width)
			} else if direction == .left {
				position.x = bounds.width - swipeGetOffset(percentage: (firstTrigger / 2), width: bounds.width)
			} else {
				return
			}
		}
		let activeViewSize: CGSize = icon.bounds.size
		var activeViewFrame: CGRect = CGRect(x: position.x - activeViewSize.width / 2.0, y: position.y - activeViewSize.height / 2.0, width: activeViewSize.width, height: activeViewSize.height)
		activeViewFrame = activeViewFrame.integral
		iconView.frame = activeViewFrame
		iconView.alpha = swipeGetAlpha(percentage: percentage)
	}

	// MARK: - END
	private func swipeDirectionBounce(duration: TimeInterval, direction: SwipeDirection, icon: UIView?, completion: SwipeCompletion?, percentage: CGFloat) {
		var icon = icon
		if let _ = icon {} else {
			icon = UIView()
		}

		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: kDamping, initialSpringVelocity: kVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
			var frame: CGRect = self.contentScreenshotView.frame
			frame.origin.x = 0
			self.contentScreenshotView.frame = frame
			// Clearing the indicator view
			self.colorIndicatorView.backgroundColor = self.defaultColor
			self.iconView.alpha = 0
			self.swipeUpdateIcon(percentage: 0, direction: direction, icon: icon!, isDragging: self.shouldAnimateIcons)
		}) { (finished) -> Void in
			if let completion = completion, !self.swipeGetBeforeTrigger(percentage: percentage, direction: direction) {
				completion(self)
				self.swipeDealloc()
			} else {
				self.isExiting = false
			}
		}
	}

	fileprivate func swipeDirectionSlide(duration: TimeInterval, direction: SwipeDirection, icon: UIView, completion: @escaping SwipeCompletion) {
		var origin: CGFloat
		if direction == .left {
			origin = -self.bounds.width
		} else if direction == .right {
			origin = self.bounds.width
		} else {
			origin = 0
		}

		let percentage: CGFloat = swipeGetPercentage(offset: origin, width: bounds.width)
		var frame: CGRect = contentScreenshotView.frame
		frame.origin.x = origin

		UIView.animate(withDuration: duration, delay: 0, options: ([.curveEaseOut, .allowUserInteraction]), animations: {() -> Void in
			self.contentScreenshotView.frame = frame
			self.iconView.alpha = 0
			self.swipeUpdateIcon(percentage: percentage, direction: direction, icon: icon, isDragging: self.shouldAnimateIcons)
		}, completion: {(finished: Bool) -> Void in
			completion(self)
			self.swipeDealloc()
		})
	}

	fileprivate func swipeDealloc() {
		// delay for animated delete of cell
		self.swipeDelegate = nil
		self.swipe = nil
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
			self.isExiting = false
			self.iconView.removeFromSuperview()
			self.colorIndicatorView.removeFromSuperview()
			self.contentScreenshotView.removeFromSuperview()
		}
	}


	// MARK: - GET
	fileprivate func swipeGetObject(percentage: CGFloat) -> SwipeObject? {
		// determine if swipe object exits
		var object: SwipeObject?
		if let left1 = Left1, percentage >= 0 {
			object = left1
		}
		if let left2 = Left2, percentage >= secondTrigger {
			object = left2
		}
		if let left3 = Left3, percentage >= thirdTrigger {
			object = left3
		}
		if let left4 = Left4, percentage >= forthTrigger {
			object = left4
		}

		if let right1 = Right1, percentage <= 0 {
			object = right1
		}
		if let right2 = Right2, percentage <= -secondTrigger {
			object = right2
		}
		if let right3 = Right3, percentage <= -thirdTrigger {
			object = right3
		}
		if let right4 = Right4, percentage <= -forthTrigger {
			object = right4
		}

		return object
	}

	fileprivate func swipeGetBeforeTrigger(percentage: CGFloat, direction: SwipeDirection) -> Bool {
		// if before the first trigger, do not run completion and bounce back
		if (direction == .left && percentage > -firstTrigger) || (direction == .right && percentage < firstTrigger) {
			return true
		}

		return false
	}


	fileprivate func swipeGetPercentage(offset: CGFloat, width: CGFloat) -> CGFloat {
		// get the percentage of the user drag
		var percentage = offset / width
		if percentage < -1.0 {
			percentage = -1.0
		} else if percentage > 1.0 {
			percentage = 1.0
		}

		return percentage
	}

	fileprivate func swipeGetOffset(percentage: CGFloat, width: CGFloat) -> CGFloat {
		// get the offset of the user drag
		var offset: CGFloat = percentage * width
		if offset < -width {
			offset = -width
		} else if offset > width {
			offset = width
		}

		return offset
	}

	fileprivate func swipeGetAnimationDuration(velocity: CGPoint) -> TimeInterval {
		// get the duration for the completing swipe
		let width: CGFloat = self.bounds.width
		let animationDurationDiff: TimeInterval = kDurationHighLimit - kDurationLowLimit
		var horizontalVelocity: CGFloat = velocity.x

		if horizontalVelocity < -width {
			horizontalVelocity = -width
		} else if horizontalVelocity > width {
			horizontalVelocity = width
		}

		let diff = abs(((horizontalVelocity / width) * CGFloat(animationDurationDiff)))

		return (kDurationHighLimit + kDurationLowLimit) - TimeInterval(diff)
	}

	func swipeGetAlpha(percentage: CGFloat) -> CGFloat {
		// set the alpha of the icon before the first trigger
		var alpha: CGFloat
		if percentage >= 0 && percentage < firstTrigger {
			alpha = percentage / firstTrigger
		} else if percentage < 0 && percentage > -firstTrigger {
			alpha = fabs(percentage / firstTrigger)
		} else {
			alpha = 1.0
		}

		return alpha
	}

	fileprivate func swipeGetDirection(percentage: CGFloat) -> SwipeDirection {
		// get the direction either left or right
		if percentage < 0 {
			return .left
		} else if percentage > 0 {
			return .right
		} else {
			return .center
		}
	}

	fileprivate func swipeGetGestureDirection(direction:SwipeDirection) -> Bool {
		// used to prevent swiping if there is not gesture in a direction
		switch direction {
		case .left:
			if let _ = Left1 {
				return true
			}
			if let _ = Left2 {
				return true
			}
			if let _ = Left3 {
				return true
			}
			if let _ = Left4 {
				return true
			}
			break
		case .right:
			if let _ = Right1 {
				return true
			}
			if let _ = Right2 {
				return true
			}
			if let _ = Right3 {
				return true
			}
			if let _ = Right4 {
				return true
			}
			break
		case .center: return false
		}

		return false
	}
}
