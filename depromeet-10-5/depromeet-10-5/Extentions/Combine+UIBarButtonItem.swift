import Combine
import UIKit

extension UIBarButtonItem {
	var tap: UIBarButtonItemPublisher<UIBarButtonItem> {
		UIBarButtonItemPublisher(control: self)
	}
}

final class UIBarButtonItemSubscription<S: Subscriber, C: UIBarButtonItem>: Subscription where S.Input == C {
	private var subscriber: S?
	private let control: C

	init(subscriber: S, control: C) {
		self.subscriber = subscriber
		self.control = control
		control.target = self
		control.action = #selector(eventHandler)
	}

	func request(_ demand: Subscribers.Demand) { }

	func cancel() {
		subscriber = nil
	}

	@objc private func eventHandler() {
		_ = subscriber?.receive(control)
	}
}

struct UIBarButtonItemPublisher<C: UIBarButtonItem>: Publisher {

	typealias Output = C
	typealias Failure = Never

	let control: C

	init(control: C) {
		self.control = control
	}

	func receive<S>(subscriber: S) where S: Subscriber,
										 S.Failure == UIBarButtonItemPublisher.Failure,
										 S.Input == UIBarButtonItemPublisher.Output {
		let subscription = UIBarButtonItemSubscription(subscriber: subscriber, control: control)
		subscriber.receive(subscription: subscription)
	}
}
