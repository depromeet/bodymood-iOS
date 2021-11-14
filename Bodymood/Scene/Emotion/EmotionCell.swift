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
        layout()
        label()
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
        label()
    }

    func layout() {
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

    func label() {
        koreanTitleLabel.font = UIFont(name: "Pretendard-Regular", size: 18)
        koreanTitleLabel.textAlignment = .center
        koreanTitleLabel.textColor = .white

        englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Regular", size: 12)
        englishTitleLabel.textAlignment = .center
        englishTitleLabel.textColor = .white
    }
    
    func labelColor(color: UIColor) {
        koreanTitleLabel.textColor = color
        englishTitleLabel.textColor = color
    }
    
    func selected() {
        koreanTitleLabel.font = UIFont(name: "Pretendard-ExtraBold", size: 18)
        koreanTitleLabel.layer.shadowColor = UIColor.black.cgColor
        koreanTitleLabel.layer.shadowRadius = 1.0
        koreanTitleLabel.layer.shadowOpacity = 0.25
        koreanTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        koreanTitleLabel.layer.masksToBounds = false
        koreanTitleLabel.alpha = 1

        englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 12)
        englishTitleLabel.layer.shadowColor = UIColor.black.cgColor
        englishTitleLabel.layer.shadowRadius = 1.0
        englishTitleLabel.layer.shadowOpacity = 0.25
        englishTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        englishTitleLabel.layer.masksToBounds = false
        englishTitleLabel.alpha = 1
    }
    
    func notSelected() {
        koreanTitleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        koreanTitleLabel.layer.shadowRadius = 0.0
        koreanTitleLabel.layer.shadowOpacity = 0.0
        koreanTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        koreanTitleLabel.layer.masksToBounds = false
        koreanTitleLabel.alpha = 0.5

        englishTitleLabel.font = UIFont(name: "PlayfairDisplay-Regular", size: 12)
        englishTitleLabel.layer.shadowRadius = 0.0
        englishTitleLabel.layer.shadowOpacity = 0.0
        englishTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        englishTitleLabel.layer.masksToBounds = false
        englishTitleLabel.alpha = 0.5
    }
}
