//
//  CameraOutputViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/25.
//

import UIKit

class CameraOutputViewController: UIViewController {
    private lazy var topView: UIView = { createTopView() }()
    private lazy var clearButton: UIButton = { createClearButton() }()
    private lazy var stackView: UIStackView = { createStackView() }()
    private lazy var saveButton: UIButton = { createSaveButton() }()
    private lazy var retakeButton: UIButton = { createRetakePhotoButton() }()

    var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
}

// MARK: - Configure Actions
extension CameraOutputViewController {
    @objc func clearButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Configure UI
extension CameraOutputViewController {
    private func layout() {
        
    }

    private func createTopView() -> UIView {
           let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }

    private func createClearButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "clear"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(clearButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createSaveButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("저장", for: .normal)
        return button
    }

    private func createRetakePhotoButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .black
        button.setTitle("다시찍기", for: .normal)
        return button
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [saveButton, retakeButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 0.0
        return stackView
    }
}
