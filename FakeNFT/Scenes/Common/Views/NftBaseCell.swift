import SnapKit
import Then
import UIKit

enum NftCellType {
    case cart
    case collection
    case myNft
    case favorite
}

class NftBaseCell: UIView {
    // MARK: - Properties
    let imgView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = .gray
    }

    let nameLabel = UILabel().then {
        $0.font = .bold17
        $0.textColor = .yBlack
    }

    let priceCaptionLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yBlack
    }

    let priceLabel = UILabel().then {
        $0.font = .medium10
        $0.textColor = .yBlack
    }

    let authorLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yBlack
        $0.text = "Author"
    }

    let ratingView = RatingView()
    let likeButton = LikeButton()
    let cartButton = CartButton()

    private var image = UIImage() {
        didSet {
            imgView.image = image
        }
    }

    private var text = "Name" {
        didSet {
            nameLabel.text = text
        }
    }

    private var author = "Author" {
        didSet {
            authorLabel.text = author
        }
    }

    private var price = "Price" {
        didSet {
            priceLabel.text = price
        }
    }

    private var rating = 4 {
        didSet {
            ratingView.setRating(rating)
        }
    }
    private var isLiked = false {
        didSet {
            likeButton.setLike(isLiked)
        }
    }
    private var isInCart = false {
        didSet {
            cartButton.setInCart(isInCart)
        }
    }

    var onLikeButtonTapped: (() -> Void)?
    var onCartButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActionHandlers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupActionHandlers()
    }

    // MARK: - Public Methods

    func configure(
        with type: NftCellType, onLike: @escaping () -> Void, onCart: @escaping () -> Void
    ) {
        configureView(for: type)
        self.onLikeButtonTapped = onLike
        self.onCartButtonTapped = onCart
    }

    func setText(_ text: String) {
        self.text = text
    }

    func setImage(_ image: UIImage) {
        self.image = image
    }

    func setImage(_ url: URL) {
        imgView.kf.setImage(with: url)
    }

    func setAuthor(_ author: String) {
        self.author = author
    }

    func setPrice(_ price: String) {
        self.price = price
    }

    func setRating(_ rating: Int) {
        self.rating = rating
    }

    func setLike(_ isLiked: Bool) {
        self.isLiked = isLiked
    }

    func setInCart(_ isInCart: Bool) {
        self.isInCart = isInCart
    }

    // MARK: - Private Methods

    private func setupActionHandlers() {
        likeButton.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartButtonTapped), for: .touchUpInside)
    }

    @objc private func handleLikeButtonTapped() {
        onLikeButtonTapped?()
    }

    @objc private func handleCartButtonTapped() {
        onCartButtonTapped?()
    }

    private func configureView(for type: NftCellType) {
        setupCommonSubviews()

        switch type {
        case .favorite:
            setupFavoriteView()
        case .myNft:
            setupMyNftView()
        case .cart:
            setupCartView()
        case .collection:
            setupCollectionView()
        }
    }

    private func setupCommonSubviews() {
        addSubview(imgView)
        addSubview(likeButton)
        addSubview(nameLabel)
        addSubview(ratingView)
        addSubview(priceLabel)
    }

    private func setupFavoriteView() {
        priceLabel.font = .regular15

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(self.snp.height)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.trailing).offset(-5)
            make.top.equalTo(imgView.snp.top).offset(5)
            make.size.equalTo(CGSize(width: 21, height: 21))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.leading.equalTo(imgView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }

        ratingView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
        }
    }

    private func setupMyNftView() {
        priceLabel.font = .bold17

        addSubview(authorLabel)
        addSubview(priceCaptionLabel)

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(self.snp.height)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.trailing).offset(-10)
            make.top.equalTo(imgView.snp.top).offset(10)
            make.size.equalTo(CGSize(width: 17, height: 17))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalTo(imgView.snp.trailing).offset(20)
            make.trailing.equalTo(priceCaptionLabel.snp.leading).offset(-16)
        }

        ratingView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        priceCaptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33)
            make.leading.equalTo(priceLabel)
            make.trailing.equalToSuperview().offset(-23)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceCaptionLabel.snp.bottom).offset(2)
            make.leading.equalTo(priceCaptionLabel)
            make.trailing.equalToSuperview().offset(-23)
        }
    }

    private func setupCartView() {
        priceLabel.font = .bold17
        cartButton.setInCart(isInCart)

        addSubview(cartButton)
        addSubview(priceCaptionLabel)

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(self.snp.height)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(imgView.snp.trailing).offset(20)
            make.trailing.equalTo(cartButton.snp.leading).offset(-16)
        }

        ratingView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        priceCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(12)
            make.leading.equalTo(nameLabel)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceCaptionLabel.snp.bottom).offset(2)
            make.leading.equalTo(nameLabel)
        }

        cartButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }
    }

    private func setupCollectionView() {
        cartButton.setInCart(isInCart)

        addSubview(cartButton)

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.trailing).offset(-10)
            make.top.equalTo(imgView.snp.top).offset(10)
            make.size.equalTo(CGSize(width: 21, height: 21))
        }

        ratingView.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalTo(cartButton.snp.leading).offset(-16)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(cartButton.snp.leading).offset(-16)
        }

        cartButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.top.equalTo(ratingView.snp.bottom).offset(15)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
}
