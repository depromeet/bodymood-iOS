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
            koreanTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 23),
            koreanTitleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            koreanTitleLabel.widthAnchor.constraint(equalToConstant: 32),
            koreanTitleLabel.heightAnchor.constraint(equalToConstant: 27)
        ])

        englishTitleLabel = UILabel()
        contentView.addSubview(englishTitleLabel)

        englishTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            englishTitleLabel.topAnchor.constraint(equalTo: koreanTitleLabel.bottomAnchor, constant: 5),
            englishTitleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            koreanTitleLabel.widthAnchor.constraint(equalToConstant: 44),
            koreanTitleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func setupLabel() {
        koreanTitleLabel.font = UIFont.systemFont(ofSize: 18)
        koreanTitleLabel.textAlignment = .center
        koreanTitleLabel.textColor = .white

        englishTitleLabel.font = UIFont.systemFont(ofSize: 12)
        englishTitleLabel.textAlignment = .center
        englishTitleLabel.textColor = .white
    }
    
    func setLabelColor(color: UIColor) {
        koreanTitleLabel.textColor = color
        englishTitleLabel.textColor = color
    }
}
