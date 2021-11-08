//
//  RemoveAccountViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/06.
//

import Combine
import UIKit

class RemoveAccountViewController: UIViewController {
    private let viewModel: RemoveAccountViewModelType

    init(viewModel: RemoveAccountViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
