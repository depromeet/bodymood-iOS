import UIKit
import Combine

class EmotionViewController: UIViewController {
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = { createCollectionViewFlowLayout() }()
    private lazy var firstTitleLabel: UILabel = { createFirstTitleLabel() }()
    private lazy var secondTitleLabel: UILabel = { createSecondTitleLabel() }()
    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var contentView: UIView = { createContentView() }()
    private lazy var bottomButton: DefaultBottomButton = { createBottomButtonView() }()
    private lazy var oldGradientLayer: CAGradientLayer = { createGradientLayer() }()

    private var emotionData: [EmotionDataResponse] = []
    private var emotionViewModel: EmotionViewModelType
    private var subscriptions = Set<AnyCancellable>()
    private var fetchSubscription: AnyCancellable?
    private var selectedIndex: Int = 17
    private var isDark: Bool = false

    weak var delegate: PosterEditDelegate?

    var selectedEmotion: EmotionDataResponse!

    private lazy var cellID = "EmotionCell"

    init(viewModel: EmotionViewModelType, emotions: [EmotionDataResponse]) {
        self.emotionViewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        collectionView.dataSource = self
        collectionView.delegate = self
        self.uploadEmotions(emotions: emotions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        style()
        layout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func bind() {
        emotionViewModel.canEnableButton.receive(on: DispatchQueue.main).sink { [weak self] canEnable in
            Log.debug(canEnable)
            self?.bottomButton.isEnabled = canEnable
        }.store(in: &subscriptions)

        emotionViewModel.buttonTitle.receive(on: DispatchQueue.main).sink { [weak self] title in
            self?.bottomButton.label.text = title
        }.store(in: &subscriptions)

        bottomButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.delegate?.emotion(emotion: (self?.selectedEmotion)!)
                self?.navigationController?.popViewController(animated: true)
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

// MARK: - Configure UI
extension EmotionViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDark ? .darkContent : .lightContent
    }

    private func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        return flowLayout
    }

    private func createFirstTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "오늘은 어떤 색상의"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }

    private func createSecondTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "감정을 느끼셨나요?"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        return label
    }

    private func createContentView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        return contentView
    }

    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: cellID)
        contentView.addSubview(collectionView)
        return collectionView
    }

    private func createBottomButtonView() -> DefaultBottomButton {
        let view = DefaultBottomButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEnabled = false
        self.view.addSubview(view)
        return view
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

        gradient(startColor: startColor, endColor: endColor)

        oldGradientLayer.colors = [startColor, endColor]
    }

    func gradient(startColor: UIColor, endColor: UIColor) {
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

    override func viewWillLayoutSubviews() {
        let startColor =  UIColor(cgColor: CGColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0))
        let endColor = UIColor(cgColor: CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0))

        gradient(startColor: startColor, endColor: endColor)
    }

    func layout() {
        NSLayoutConstraint.activate([
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            firstTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            firstTitleLabel.widthAnchor.constraint(equalToConstant: 139),
            firstTitleLabel.heightAnchor.constraint(equalToConstant: 27),
            firstTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            secondTitleLabel.topAnchor.constraint(equalTo: firstTitleLabel.topAnchor, constant: 30),
            secondTitleLabel.widthAnchor.constraint(equalToConstant: 139),
            secondTitleLabel.heightAnchor.constraint(equalToConstant: 27),
            secondTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: secondTitleLabel.bottomAnchor, constant: 67),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -92),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
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

// MARK: - Configure Collection View
extension EmotionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emotionData.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
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
                cell.koreanTitleLabel.font = UIFont(name: "Pretendard-ExtraBold", size: 18)
                cell.koreanTitleLabel.layer.shadowColor = UIColor.black.cgColor
                cell.koreanTitleLabel.layer.shadowRadius = 1.0
                cell.koreanTitleLabel.layer.shadowOpacity = 0.25
                cell.koreanTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.koreanTitleLabel.layer.masksToBounds = false
                cell.koreanTitleLabel.alpha = 1

                cell.englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 12)
                cell.englishTitleLabel.layer.shadowColor = UIColor.black.cgColor
                cell.englishTitleLabel.layer.shadowRadius = 1.0
                cell.englishTitleLabel.layer.shadowOpacity = 0.25
                cell.englishTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.englishTitleLabel.layer.masksToBounds = false
                cell.englishTitleLabel.alpha = 1

                let startColor = hexStringToUIColor(hex: emotionData[selectedIndex].startColor!)
                let endColor = hexStringToUIColor(hex: emotionData[selectedIndex].endColor!)

                gradient(startColor: startColor, endColor: endColor)

            } else {
                cell.koreanTitleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
                cell.koreanTitleLabel.layer.shadowRadius = 0.0
                cell.koreanTitleLabel.layer.shadowOpacity = 0.0
                cell.koreanTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.koreanTitleLabel.layer.masksToBounds = false
                cell.koreanTitleLabel.alpha = 0.5

                cell.englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Regular", size: 12)
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
        emotionViewModel.itemTapped.send(indexPath.item)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int)
    -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 23, right: 0)
    }
}
