import UIKit

final class NftCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let baseCell = NftBaseCell()

    private var onLikeButtonTapped: (() -> Void)?
    private var onCartButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBaseCell()
    }

    // MARK: - Public Methods

    func configure(
        with type: NftCellType, onLike: @escaping () -> Void, onCart: @escaping () -> Void
    ) {
        baseCell.configure(with: type, onLike: onLike, onCart: onCart)
    }

    func setText(_ text: String) {
        baseCell.setText(text)
    }

    func setImage(_ image: UIImage) {
        baseCell.setImage(image)
    }

    func setImage(_ url: URL) {
        baseCell.setImage(url)
    }

    func setAuthor(_ author: String) {
        baseCell.setAuthor(author)
    }

    func setPrice(_ price: String) {
        baseCell.setPrice(price)
    }

    func setRating(_ rating: Int) {
        baseCell.setRating(rating)
    }

    func setLike(_ isLiked: Bool) {
        baseCell.setLike(isLiked)
    }

    func setInCart(_ isInCart: Bool) {
        baseCell.setInCart(isInCart)
    }

    // MARK: - Private Methods

    private func setupBaseCell() {
        contentView.addSubview(baseCell)
        baseCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
