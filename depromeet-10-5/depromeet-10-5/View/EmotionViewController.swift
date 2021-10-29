//
//  EmotionViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/26.
//

import UIKit
import Combine

class EmotionViewController: UIViewController {
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = { createCollectionViewFlowLayout() }()
    private lazy var firstTitleLabel: UILabel = { createFirstTitleLabel() }()
    private lazy var secondTitleLabel: UILabel = { createSecondTitleLabel() }()
    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var contentView: UIView = { createContentView() }()
    private lazy var selectButton: UIButton = { createSelectButton() }()
    private lazy var oldGradientLayer: CAGradientLayer = { createGradientLayer() }()

    private var emotionData: [EmotionDataResponse] = []
    private var emotionViewModel: EmotionViewModelType
    private var subscriptions: Set<AnyCancellable> = []
    private var fetchSubscription: AnyCancellable?
    private var selectedIndex: Int = 17
    private var isDark: Bool = false

    weak var delegate: PosterEditDelegate?

    var selectedEmotion: EmotionDataResponse!

    private lazy var cellID = "EmotionCell"

    init(viewModel: EmotionViewModelType) {
        self.emotionViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDark ? .darkContent : .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        style()
        layout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func bind() {
        let emotionCategories =
        emotionViewModel.emotionCategories()

        emotionCategories.receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                Log.debug("success bind method in view")
                self?.uploadEmotions(emotions: response)
        }.store(in: &subscriptions)
    }

    func uploadEmotions(emotions: [EmotionDataResponse]) {
        for index in 0..<emotions.count {
            emotionData.insert(emotions[index], at: index)
        }

        for emotion in emotions {
            Log.debug(emotion)
        }

        collectionView.reloadData()
    }
}

extension EmotionViewController {
    private func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        return flowLayout
    }

    private func createFirstTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "오늘은 어떤 색상의"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center

        return label
    }

    private func createSecondTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "감정을 느끼셨나요?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center

        return label
    }

    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }

    private func createContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    private func createSelectButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor(cgColor: CGColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0))
        button.setTitleColor(.white, for: .normal)
        button.setTitle("감정 선택", for: .normal)
        button.addTarget(self, action: #selector(selectButtonDidTap), for: .touchUpInside)
        button.isEnabled = false
        return button
    }

    private func createGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        return gradientLayer
    }

    func style() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear

        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "back") {
            backButton.setImage(image, for: .normal)
        }
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white

        view.backgroundColor = .white

        let startColor =  UIColor(cgColor: CGColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0))
        let endColor = UIColor(cgColor: CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0))

        gradientLocation(startColor: startColor, endColor: endColor)

        oldGradientLayer.colors = [startColor, endColor]
    }

    func gradientLocation(startColor: UIColor, endColor: UIColor) {
        let gradientLayerName = "gradientLayer"

        if let oldLayer = view.layer.sublayers?.filter({$0.name == gradientLayerName}).first {
            oldLayer.removeFromSuperlayer()
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        gradientLayer.name = gradientLayerName

        view.layer.insertSublayer(gradientLayer, at: 0)

        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0, 0.1]
        gradientAnimation.toValue = [0, 1.0]
        gradientAnimation.duration = 2.0
        gradientAnimation.repeatCount = 1
        gradientLayer.add(gradientAnimation, forKey: nil)
    }

    func layout() {
        view.addSubview(selectButton)
        selectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            selectButton.heightAnchor.constraint(equalToConstant: 64),
            selectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(firstTitleLabel)
        firstTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 74),
            firstTitleLabel.widthAnchor.constraint(equalToConstant: 139),
            firstTitleLabel.heightAnchor.constraint(equalToConstant: 27),
            firstTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(secondTitleLabel)
        secondTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondTitleLabel.topAnchor.constraint(equalTo: firstTitleLabel.topAnchor, constant: 30),
            secondTitleLabel.widthAnchor.constraint(equalToConstant: 139),
            secondTitleLabel.heightAnchor.constraint(equalToConstant: 27),
            secondTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: secondTitleLabel.bottomAnchor, constant: 67),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            contentView.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: -92),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])

        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])

        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: cellID)
    }

    func hexStringToUIColor(hex: String) -> UIColor {
        var upperString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if upperString.hasPrefix("#") {
            upperString.remove(at: upperString.startIndex)
        }

        if upperString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: upperString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


// - MARK: Configure actions
extension EmotionViewController {
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func selectButtonDidTap() {
        delegate?.emotion(emotion: selectedEmotion)
        navigationController?.popViewController(animated: true)
    }
}

extension EmotionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emotionData.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        Log.debug("cell \(indexPath.row) is updating")
        guard let cell =  collectionView.dequeueReusableCell(
            withReuseIdentifier: cellID,
            for: indexPath) as? EmotionCell else {
            return UICollectionViewCell()
        }

        cell.backgroundColor = .clear
        cell.koreanTitleLabel.text = emotionData[indexPath.row].koreanTitle
        cell.englishTitleLabel.text = emotionData[indexPath.row].englishTitle
        cell.setLabelColor(color: hexStringToUIColor(
            hex: emotionData[selectedIndex == 17 ? 0: selectedIndex].fontColor ?? "#FFFFFF")
        )

        if selectedIndex != 17 {
            if indexPath.row == selectedIndex {
                cell.koreanTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                cell.koreanTitleLabel.layer.shadowColor = UIColor.black.cgColor
                cell.koreanTitleLabel.layer.shadowRadius = 1.0
                cell.koreanTitleLabel.layer.shadowOpacity = 0.25
                cell.koreanTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.koreanTitleLabel.layer.masksToBounds = false
                cell.koreanTitleLabel.alpha = 1

                cell.englishTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                cell.englishTitleLabel.layer.shadowColor = UIColor.black.cgColor
                cell.englishTitleLabel.layer.shadowRadius = 1.0
                cell.englishTitleLabel.layer.shadowOpacity = 0.25
                cell.englishTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.englishTitleLabel.layer.masksToBounds = false
                cell.englishTitleLabel.alpha = 1

            } else {
                cell.koreanTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                cell.koreanTitleLabel.layer.shadowRadius = 0.0
                cell.koreanTitleLabel.layer.shadowOpacity = 0.0
                cell.koreanTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.koreanTitleLabel.layer.masksToBounds = false
                cell.koreanTitleLabel.alpha = 0.5

                cell.englishTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                cell.englishTitleLabel.layer.shadowRadius = 0.0
                cell.englishTitleLabel.layer.shadowOpacity = 0.0
                cell.englishTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.englishTitleLabel.layer.masksToBounds = false
                cell.englishTitleLabel.alpha = 0.5
            }
        }
        return cell
    }
}

extension EmotionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedIndex = indexPath.row
        selectedEmotion = emotionData[selectedIndex]

        firstTitleLabel.isHidden = true
        secondTitleLabel.isHidden = true

        let startColor = hexStringToUIColor(
            hex: emotionData[selectedIndex == 17 ? 0: selectedIndex].startColor ?? "#C1C1C1"
        )
        let endColor = hexStringToUIColor(
            hex: emotionData[selectedIndex == 17 ? 0: selectedIndex].endColor ?? "#979797"
        )

        gradientLocation(startColor: startColor, endColor: endColor)

        selectButton.backgroundColor = .black
        selectButton.setTitle("선택 완료", for: .normal)
        selectButton.isEnabled = true

        let backButton = UIButton(type: .custom)

        let fontColor = emotionData[indexPath.row].fontColor ?? "#ffffff"

        if fontColor == "#ffffff" {
            isDark = false
            setNeedsStatusBarAppearanceUpdate()

            if let image = UIImage(named: "back") {
                backButton.setImage(image, for: .normal)
            }
        } else if fontColor == "#000000" {
            isDark = true
            setNeedsStatusBarAppearanceUpdate()

            if let image = UIImage(named: "back_black") {
                backButton.setImage(image, for: .normal)
            }
        }

        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)

        let leftBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButton

        collectionView.reloadData()
    }
}

extension EmotionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        return CGSize(width: contentView.frame.width * (1/4), height: contentView.frame.height * (1/5))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int)
    -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int)
    -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 23, right: 0)
    }
}

class EmotionNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
