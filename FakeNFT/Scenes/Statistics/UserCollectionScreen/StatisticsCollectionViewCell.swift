import UIKit
import SnapKit
import Then
import Kingfisher

final class StatisticsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NFTCell"
    
    private var isLiked = false
    private var isInCart = false
    
    private lazy var nftPictureImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var likeButton = UIButton().then {
        $0.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        $0.backgroundColor = .clear
    }
    
    private lazy var nftNameLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.textColor = .yBlackUniversal
    }
    
    private lazy var nftCostLabel = UILabel().then {
        $0.font = UIFont.medium10
        $0.textColor = .yBlackUniversal
    }
    
    private lazy var cartButton = UIButton().then {
        $0.addTarget(self, action: #selector(cartButtonDidTap), for: .touchUpInside)
        $0.backgroundColor = .clear
    }
    
    private lazy var starsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .fill
        $0.distribution = .fillEqually
        for _ in 0..<5 {
            let starImageView = UIImageView(image: UIImage(named: "InactiveStar"))
            $0.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(for nft: Nft) {
        nftPictureImageView.kf.setImage(with: URL(string: nft.images[0]))
        nftNameLabel.text = nft.name
        nftCostLabel.text = "\(nft.price) ETH"
        likeButton.setImage(UIImage.favoriteInactive, for: .normal)
        cartButton.setImage(UIImage.addToCart, for: .normal)
        
        updateStars(rating: nft.rating)
    }
    
    private func updateStars(rating: Int) {
        for (index, starView) in starsStackView.arrangedSubviews.enumerated() {
            guard let imageView = starView as? UIImageView else { continue }
            imageView.image = UIImage(named: index < rating ? "ActiveStar" : "InactiveStar")
        }
    }
    
    // MARK: - View Configuration
    private func setupConstraints() {
        contentView.addSubview(nftPictureImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(starsStackView)
        contentView.addSubview(nftNameLabel)
        contentView.addSubview(nftCostLabel)
        contentView.addSubview(cartButton)
        
        nftPictureImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(8)
            make.height.width.equalTo(108)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(42)
            make.top.right.equalTo(nftPictureImageView)
        }
        
        starsStackView.snp.makeConstraints { make in
            make.top.equalTo(nftPictureImageView.snp.bottom).offset(8)
            make.left.equalTo(nftPictureImageView)
            make.height.equalTo(12)
            make.width.equalTo(68)
        }
        
        nftNameLabel.snp.makeConstraints { make in
            make.top.equalTo(starsStackView.snp.bottom).offset(8)
            make.left.equalTo(nftPictureImageView)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(22)
        }
        
        nftCostLabel.snp.makeConstraints { make in
            make.top.equalTo(nftNameLabel.snp.bottom).offset(4)
            make.left.equalTo(nftPictureImageView)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(12)
        }
        
        cartButton.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalTo(nftCostLabel.snp.centerY).offset(-5)
            make.trailing.equalTo(nftPictureImageView.snp.trailing)
        }
    }
    
    // MARK: - Actions
    @objc private func likeButtonDidTap() {
        let image: UIImage = isLiked ? .favoriteInactive : .favoriteActive
        likeButton.setImage(image, for: .normal)
        isLiked.toggle()
    }
    
    @objc private func cartButtonDidTap() {
        let image: UIImage = isInCart ? .addToCart : .removeFromCart
        cartButton.setImage(image, for: .normal)
        isInCart.toggle()
    }
}
