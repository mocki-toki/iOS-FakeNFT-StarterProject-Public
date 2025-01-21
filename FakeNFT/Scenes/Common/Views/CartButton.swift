import SnapKit
import UIKit

final class CartButton: UIButton {
    // MARK: - Properties
    private var isInCart: Bool = false {
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

    func setInCart(_ isInCart: Bool) {
        self.isInCart = isInCart
    }

    // MARK: - Private methods

    private func setupView() {
        imageView?.contentMode = .scaleAspectFit
        setImage(.addToCart, for: .normal)
    }

    private func updateAppearance() {
        let image = isInCart ? UIImage.removeFromCart : UIImage.addToCart
        let tintedImage = image.withTintColor(.yBlack, renderingMode: .alwaysOriginal)
        setImage(tintedImage, for: .normal)
    }
}
