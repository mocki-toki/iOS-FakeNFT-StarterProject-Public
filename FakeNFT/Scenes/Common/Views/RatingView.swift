import SnapKit
import Then
import UIKit

class RatingView: UIView {
    // MARK: - Constants
    enum Constants {
        static let maximumRating = 5
        static let starSize = CGSize(width: 12, height: 12)
        static let starSpacing: CGFloat = 2
    }

    // MARK: - Properties
    private var currentRating: Int = 0 {
        didSet {
            updateStars()
        }
    }

    private var starStackView: UIStackView!

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        starStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = Constants.starSpacing
        }
        addSubview(starStackView)

        starStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for index in 1...Constants.maximumRating {
            let starView = UIImageView().then {
                $0.tag = index
                $0.image = .inactiveStar
            }
            starStackView.addArrangedSubview(starView)

            starView.snp.makeConstraints { make in
                make.size.equalTo(Constants.starSize)
            }
        }
    }

    // MARK: - Update UI
    private func updateStars() {
        for starView in starStackView.arrangedSubviews {
            if let imageView = starView as? UIImageView {
                imageView.image = imageView.tag <= currentRating ? .activeStar : .inactiveStar
            }
        }
    }

    // MARK: - Public Methods
    func setRating(_ rating: Int) {
        currentRating = min(max(rating, 0), Constants.maximumRating)
    }
}
