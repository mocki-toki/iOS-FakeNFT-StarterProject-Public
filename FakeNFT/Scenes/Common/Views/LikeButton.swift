import SnapKit
import UIKit

final class LikeButton: UIButton {
    // MARK: - Properties
    private var isLiked: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateAppearance()
    }
    
    // MARK: - Public methods
    
    func setLike(_ isLiked: Bool) {
        self.isLiked = isLiked
    }

    // MARK: - Private methods

    private func setupView() {
        imageView?.contentMode = .scaleAspectFit
        setImage(.favoriteInactive, for: .normal)
    }

    private func updateAppearance() {
        setImage(isLiked ? .favoriteActive : .favoriteInactive, for: .normal)
    }
}
