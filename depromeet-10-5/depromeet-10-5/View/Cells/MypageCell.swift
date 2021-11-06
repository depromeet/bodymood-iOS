//
//  MypageCell.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/11/06.
//

import UIKit

class MypageCell: UICollectionViewCell {
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    func update(title: String) {
        self.title.text = title
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
}
