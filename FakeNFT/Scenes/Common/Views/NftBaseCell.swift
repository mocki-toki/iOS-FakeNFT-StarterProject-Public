import UIKit
import SnapKit
import Then

enum NftCellType {
    case cart
    case collection
    case myNft
    case favorite
}

final class NftBaseCell: UIView {
    // MARK: - Properties
    private let imgView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = .gray
    }

    private let nameLabel = UILabel().then {
        $0.font = .bold17
        $0.textColor = .yBlack
    }

    private let priceCaptionLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yBlack
        $0.text = String(localizable: .cellPriceCaptionLabel)
    }

    private let priceLabel = UILabel().then {
        $0.font = .medium10
        $0.textColor = .yBlack
    }

    private let authorLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yBlack
        $0.text = "Author"
    }

    private let ratingView = RatingView()
    private let likeButton = LikeButton()
    private let cartButton = CartButton()

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
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }

    private var onLikeButtonTapped: (() -> Void)?
    private var onCartButtonTapped: (() -> Void)?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActionHandlers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupActionHandlers()
    }

    // MARK: - Public methods

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
    
    func setImage(_ url: URL) {
        imgView.kf.setImage(with: url)
    }

    func setImage(_ image: UIImage) {
        self.image = image
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
    
    func setPriceCaption(_ caption: String) {
        self.priceCaptionLabel.text = caption
    }

    // MARK: - Private methods

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
            make.trailing.equalTo(imgView.snp.trailing).offset(5)
            make.top.equalTo(imgView.snp.top).offset(-6)
            make.size.equalTo(CGSize(width: 42, height: 42))
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
        nameLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail

        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        [imgView, likeButton,
            nameLabel, ratingView, authorLabel,
            priceCaptionLabel, priceLabel
        ].forEach {
            containerView.addSubview($0)
        }

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(containerView.snp.height)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.trailing)
            make.top.equalTo(imgView.snp.top)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalTo(imgView.snp.trailing).offset(20)
            make.width.lessThanOrEqualTo(110)
        }

        ratingView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.width.lessThanOrEqualTo(nameLabel)
        }

        priceCaptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33)
            make.leading.equalTo(priceLabel)
            make.trailing.equalToSuperview().offset(-23)
            make.width.equalTo(priceLabel)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceCaptionLabel.snp.bottom).offset(2)
            make.leading.equalTo(priceCaptionLabel)
            make.trailing.equalToSuperview().offset(-23)
            make.width.greaterThanOrEqualTo(70)
        }
    }

    private func setupCartView() {
        priceLabel.font = .bold17
        cartButton.setInCart(true)
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        [imgView, ratingView, nameLabel, priceCaptionLabel, priceLabel, cartButton]
            .forEach {
                containerView.addSubview($0)
            }
        
        imgView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(containerView.snp.height)
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

        [imgView, likeButton, ratingView, nameLabel, priceLabel, cartButton].forEach {
            addSubview($0)
        }

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }

        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.trailing)
            make.top.equalTo(imgView.snp.top)
            make.size.equalTo(CGSize(width: 38, height: 38))
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
