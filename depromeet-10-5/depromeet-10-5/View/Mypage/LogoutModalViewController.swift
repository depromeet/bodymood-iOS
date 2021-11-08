import UIKit

class LogoutModalViewController: UIViewController {
    private lazy var containerView: UIView = {
        createContainerLabel() }()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var logoutView: UIView = { createLogoutView() }()
    private lazy var cancelView: UIView = { createCancelView() }()
    private lazy var stackView: UIView = { createStackView() }()

    private lazy var logoutButton: UIButton = { createLogoutButton() }()
    private lazy var cancelButton: UIButton = { createCancelButton() }()

    private let maxDimmedAlpha = Layout.maxDimmedAlpha

    private lazy var dimmedView: UIView = { createDimmedView() }()

    private let defaultHeight =  Layout.defaultHeight
    private let dismissibleHeight = Layout.defaultHeight
    private let maximumContainerHeight = Layout.defaultHeight
    
    private var currentContainerHeight = Layout.defaultHeight
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)

        panGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
}

extension LogoutModalViewController {
    private func createContainerLabel() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createDimmedView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }

    private func createLogoutView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLogoutButton() -> UIButton {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        logoutView.addSubview(button)
        return button
    }

    private func createCancelView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        cancelView.addSubview(button)
        return button
    }
    
    private func createStackView() -> UIView {
        let stackView = UIStackView(arrangedSubviews: [logoutView, cancelView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "로그아웃을 하시겠습니까?"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }

    private func style () {
        view.backgroundColor = .clear
    }

    private func layout() {
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 19)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 39),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -23)
        ])

        NSLayoutConstraint.activate([
            logoutView.heightAnchor.constraint(equalToConstant: 56),
            cancelView.heightAnchor.constraint(equalToConstant: 56)
        ])

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: logoutView.topAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: logoutView.leadingAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: logoutView.bottomAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: logoutView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: cancelView.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: cancelView.leadingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: cancelView.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: cancelView.trailingAnchor)
        ])

        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView
            .bottomAnchor
            .constraint(equalTo: view.bottomAnchor, constant: defaultHeight)

        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }

    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }

    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }

    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }

        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }

    enum Layout {
        static let defaultHeight = 169.0
        static let maxDimmedAlpha = 0.5
    }
}

// MARK: - Configure Actions
extension LogoutModalViewController {
    @objc func handleCloseAction() {
        animateDismissView()
    }

    private func panGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        let newHeight = currentContainerHeight - translation.y

        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
        default:
            break
        }
    }
}
