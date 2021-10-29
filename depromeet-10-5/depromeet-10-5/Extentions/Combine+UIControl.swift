import Combine
import UIKit

extension UIControl {
	func publisher(for events: UIControl.Event) -> UIControlPublisher<UIControl> {
		return UIControlPublisher(control: self, events: events)
	}
}

final class UIControlSubscription<S: Subscriber, C: UIControl>: Subscription where S.Input == C {
	private var subscriber: S?
	private let control: C

	init(subscriber: S, control: C, event: UIControl.Event) {
		self.subscriber = subscriber
		self.control = control
		control.addTarget(self, action: #selector(eventHandler), for: event)
	}

	func request(_ demand: Subscribers.Demand) { }

	func cancel() {
		subscriber = nil
	}

	@objc private func eventHandler() {
		_ = subscriber?.receive(control)
	}
}

struct UIControlPublisher<C: UIControl>: Publisher {

	typealias Output = C
	typealias Failure = Never

	let control: C
	let controlEvents: UIControl.Event

	init(control: C, events: UIControl.Event) {
		self.control = control
		self.controlEvents = events
	}

	func receive<S>(subscriber: S) where S: Subscriber,
										 S.Failure == UIControlPublisher.Failure,
										 S.Input == UIControlPublisher.Output {
		let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
		subscriber.receive(subscription: subscription)
	}
}



