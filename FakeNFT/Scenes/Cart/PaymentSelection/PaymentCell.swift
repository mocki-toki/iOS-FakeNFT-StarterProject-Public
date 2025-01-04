import UIKit
import SnapKit
import Then
import Kingfisher

final class PaymentCell: UICollectionViewCell {
    static let identifier = "PaymentCell"
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yBlack
        $0.numberOfLines = 1
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .yGreenUniversal
        $0.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        Logger.log("PaymentCell initialization through NSCoder is not supported", level: .error)
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with method: PaymentMethod) {
        Logger.log("Configuring PaymentCell with \(method.title)", level: .debug)
        let placeholder = UIImage(named: "CurrencyPlaceholder")
        
        if let url = method.imageUrl {
            iconImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            ) { result in
                switch result {
                case .success(let value):
                    Logger.log("Image loaded successfully: \(value.source.url?.absoluteString ?? "Unknown URL")")
                case .failure(let error):
                    Logger.log("Failed to load image: \(error.localizedDescription)", level: .error)
                }
            }
        } else {
            iconImageView.image = placeholder
        }
        
        titleLabel.text = method.title
        subtitleLabel.text = method.name
    }
    
    override var isSelected: Bool {
        didSet {
            Logger.log("Cell selection changed to \(isSelected)")
            contentView.layer.borderWidth = isSelected ? 1 : 0
            contentView.layer.borderColor = isSelected ? UIColor.yBlack.cgColor : UIColor.clear.cgColor
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = .yLightGrey
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(6)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
}
