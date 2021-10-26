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
    private lazy var collectionView: UICollectionView = { createCollectionView() }()
    private lazy var contentView: UIView = { createContentView() }()
    
    private var emotionArray: [EmotionDataResponse]?
    private var emotionViewModel: EmotionViewModelType
    private var subscriptions: Set<AnyCancellable> = []
    
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

    override func viewWillAppear(_ animated: Bool) {
        style()
        layout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        let emotionCategories =
        emotionViewModel.emotionCategories()

        emotionCategories.receive(on: DispatchQueue.main).sink {response in
            Log.debug("success bind method")

            for value in response {
                Log.debug(value)
                self.emotionArray?.append(value)
            }

        }.store(in: &subscriptions)
    }
}

extension EmotionViewController {
    private func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        return flowLayout
    }

    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .yellow
        return collectionView
    }

    private func createContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }

    func style() {
        collectionView.dataSource = self
        collectionView.delegate = self
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
    }

    func layout() {
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 304),
            contentView.heightAnchor.constraint(equalToConstant: 448)
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
}

extension EmotionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
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

        cell.backgroundColor = .red

        let titleString = emotionArray?[indexPath.row].title
        let emotionTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 27))
        emotionTitle.text = titleString
        emotionTitle.textColor = .black

        cell.contentView.addSubview(emotionTitle)

        NSLayoutConstraint.activate([
            emotionTitle.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            emotionTitle.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])

        return cell
    }
}

extension EmotionViewController: UICollectionViewDelegate {

}

extension EmotionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        return CGSize(width: 76, height: 94)
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
