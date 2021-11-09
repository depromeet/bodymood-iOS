//
//  UserInfoViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/06.
//

import Combine
import UIKit

class UserInfoViewController: UIViewController {
    private let viewModel: UserInfoViewModelType
    private var subscriptions = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var contentLabel: UILabel = { createContentLabel() }()
    
    init(viewModel: UserInfoViewModelType) {
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
        style()
        layout()
        bind()
    }
}

// MARK: - Configure bind
extension UserInfoViewController {
    private func bind() {
        viewModel.title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &subscriptions)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
    }
}

// MARK: - Configure UI
extension UserInfoViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = label
        return label
    }

    private func createContentLabel() -> UILabel {
        let label = UILabel()
        label.text = "Comimg Soon"
        label.font = UIFont(name: "PlayfairDisplay-Bold", size: 35)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }

    private func style() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = .init(
            image: UIImage(named: "back_black"),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    private func layout() {
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
