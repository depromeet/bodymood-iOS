import UIKit
import Combine

class PageIndicator: UIView {
    let offsetX = PassthroughSubject<CGFloat, Never>()
    let moveToPage = PassthroughSubject<Int, Never>()
    private var bag = Set<AnyCancellable>()

    var numberOfPages: Int {
        didSet {
            widthConstraint.isActive = false
            widthConstraint = bar.widthAnchor.constraint(equalTo: widthAnchor,
                                                         multiplier: 1 / CGFloat(numberOfPages))
            widthConstraint.isActive = true
            layoutIfNeeded()
        }
    }

    private lazy var widthConstraint: NSLayoutConstraint = {
        bar.widthAnchor.constraint(equalTo: widthAnchor)
    }()

    lazy var bar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    init() {
        numberOfPages = 0
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.debug(Self.self, #function)
    }

    private func setup() {
        configure()
        layout()
        bind()
    }

    private func configure() {
        backgroundColor = .gray
        bar.backgroundColor = .black
        clipsToBounds = true
    }

    private func layout() {
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalTo: heightAnchor),
            widthConstraint
        ])
    }

    private func bind() {
        offsetX
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offsetX in
                guard let self = self else { return }
                self.bar.frame.origin.x = self.frame.width * offsetX
            }.store(in: &bag)
        
        moveToPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idx in
                guard let self = self else { return }
                self.bar.frame.origin.x = self.frame.width * CGFloat(idx) / CGFloat(self.numberOfPages)
            }.store(in: &bag)
    }
}
