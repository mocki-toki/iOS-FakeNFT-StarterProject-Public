import UIKit

final class NftDetailsCurrencyCollectionCell: UICollectionViewCell, ReuseIdentifying {
    // MARK: - Properties

    private let coverImageView = UIImageView().then {
        $0.layer.cornerRadius = 6
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.backgroundColor = .yBlack
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .regular13
    }
    
    private let subtitleLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .regular15
        $0.text = "$18.11"
    }
    
    private let trailingLabel = UILabel().then {
        $0.textColor = .yGreenUniversal
        $0.font = .regular13
    }

    // MARK: - Public functions

    func configure(with model: NftDetailsCurrencyModel) {
        coverImageView.kf.setImage(with: model.imageUrl)
        titleLabel.text = "\(model.title) (\(model.name))"
        trailingLabel.text = "0,1 (\(model.name))"

        setupLayout()
    }

    // MARK: - Private functions

    private func setupLayout() {
        [coverImageView, titleLabel, subtitleLabel, trailingLabel].forEach {
            contentView.addSubview($0)
        }

        coverImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(10)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(10)
        }
        
        trailingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
