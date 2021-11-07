import UIKit

class PosterView: UIView {

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    private lazy var exerciseStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: (1...3).map { _ in createExerciseLabel() })
        view.axis = .vertical
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    private func createExerciseLabel() -> UILabel {
        let view = UILabel()
        view.font = UIFont(name: "PlayfairDisplay-Bold", size: 36)
        view.textColor = .white
        return view
    }

    private lazy var emotionStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [emotionGuideLabel, emotionLabel])
        view.axis = .vertical
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    private lazy var emotionGuideLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "PlayfairDisplay-Bold", size: 18)
        view.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
        view.text = "Today's Bodymood"
        return view
    }()

    private lazy var emotionLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "PlayfairDisplay-Bold", size: 24)
        view.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()

    init() {
        super.init(frame: .zero)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makePoster(_ image: UIImage, _ exercises: [ExerciseCategoryModel], _ emotion: EmotionDataResponse) {
        let value1 = Int(UInt32(emotion.startColor?.dropFirst() ?? "", radix: 16) ?? 0)
        let value2 = Int(UInt32(emotion.endColor?.dropFirst() ?? "", radix: 16) ?? 0)
        imageView.addDiagonalGradiant(startColor: UIColor(rgb: value1).withAlphaComponent(0.5),
                                      endColor: UIColor(rgb: value2).withAlphaComponent(0.5))
        exerciseStackView.isHidden = false
        emotionStackView.isHidden = false
        imageView.image = image

        exercises.enumerated().forEach { idx, model in
            (exerciseStackView.arrangedSubviews[safe: idx] as? UILabel)?.text = model.englishName
        }
        emotionLabel.text = emotion.englishTitle

        updateFonts()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFonts()
    }

    private func updateFonts() {
        guard let label = exerciseStackView.arrangedSubviews.first as? UILabel else { return }

        var ratio = exerciseStackView.frame.height / bounds.height
        if ratio < 0.24 { return }

        ratio /= 0.24

        let textSize = label.font.pointSize / ratio
        exerciseStackView.arrangedSubviews.compactMap { $0 as? UILabel }.forEach {
            $0.font = $0.font.withSize(textSize)
        }

        emotionLabel.font = emotionLabel.font.withSize(emotionLabel.font.pointSize / ratio)
        emotionGuideLabel.font = emotionGuideLabel.font.withSize(emotionGuideLabel.font.pointSize / ratio)

        layoutIfNeeded()
        fixFontSizes()
    }

    func fixFontSizes() {
        let list = exerciseStackView.arrangedSubviews.compactMap { $0 as? UILabel }

        let maxLabelWidth = exerciseStackView.bounds.width
        var largestLabelWidth: CGFloat = 0
        list.forEach { label in
            largestLabelWidth = max(largestLabelWidth, label.text?.width(constrainedBy: label.bounds.height,
                                                       with: label.font) ?? 0)
        }

        guard largestLabelWidth > maxLabelWidth else { return }

        let largestTextSize = list[0].font.pointSize

        let labelToScreenWidthRatio = largestLabelWidth / maxLabelWidth
        let calculatedMaxTextSize = floor(largestTextSize / labelToScreenWidthRatio)

        list.forEach { label in
            label.font = label.font.withSize(calculatedMaxTextSize)
        }
    }

    private func layout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            exerciseStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            exerciseStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                       constant: Layout.exerciseStackViewOffset),
            exerciseStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
                                                        constant: -Layout.exerciseStackViewOffset)
        ])

        NSLayoutConstraint.activate([
            emotionStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: Layout.emotionStackViewOffset),
            emotionStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -Layout.emotionStackViewOffset),
            emotionStackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                     constant: -Layout.emotionStackViewOffset)
        ])
    }

    enum Layout {
        static let emotionStackViewOffset: CGFloat = 10
        static let exerciseStackViewOffset: CGFloat = 5
    }
}

extension String {
    func height(constrainedBy width: CGFloat, with font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return boundingBox.height
    }

    func width(constrainedBy height: CGFloat, with font: UIFont) -> CGFloat {
        let constrainedRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constrainedRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return boundingBox.width
    }
}
