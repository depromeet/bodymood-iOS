//
//  EmotionCell.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/10/26.
//

import UIKit

class EmotionCell: UICollectionViewCell {
    var koreanTitleLabel: UILabel!
    var englishTitleLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
        setupLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCell()
        setupLabel()
    }

    func setUpCell() {
        koreanTitleLabel = UILabel()
        contentView.addSubview(koreanTitleLabel)
        
        koreanTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            koreanTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            koreanTitleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            koreanTitleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])

        englishTitleLabel = UILabel()
        contentView.addSubview(englishTitleLabel)

        englishTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            englishTitleLabel.topAnchor.constraint(equalTo: koreanTitleLabel.bottomAnchor, constant: 5),
            englishTitleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 23),
            englishTitleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
    }

    func setupLabel() {
        koreanTitleLabel.font = UIFont.systemFont(ofSize: 18)
        koreanTitleLabel.textAlignment = .center
        englishTitleLabel.font = UIFont.systemFont(ofSize: 12)
        englishTitleLabel.textAlignment = .center
    }
}
