//
//  AuthCoordinatorProtocol.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/16.
//

import Foundation
import UIKit

enum Event {
    case buttonDidTap
}

protocol AuthCoordinatorProtocol {
    var navigationController: UINavigationController? { get set }

    func eventOccured(with type: Event)
    func start()
}

protocol AuthCoordinating {
    var coordinator: AuthCoordinatorProtocol? { get set }
}
