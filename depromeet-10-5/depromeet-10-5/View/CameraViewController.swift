//
//  CameraViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/16.
//

import UIKit

class CameraViewController: UIViewController, AuthCoordinating {
    var coordinator: AuthCoordinatorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Camera"
        view.backgroundColor = .systemBlue
    }
}
