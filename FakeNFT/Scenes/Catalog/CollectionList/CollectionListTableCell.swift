import UIKit

final class CollectionListTableCell: UITableViewCell, ReuseIdentifying {
    // MARK: - Properties

    private let coverImageView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    private let nameLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .bold17
    }

    // MARK: - Public functions

    func configure(with model: CollectionListTableCellModel) {
        coverImageView.kf.setImage(with: model.coverUrl)
        nameLabel.text = "\(model.name) (\(model.count))"

        setupLayout()
    }

    // MARK: - Private functions

    private func setupLayout() {
        [coverImageView, nameLabel].forEach {
            contentView.addSubview($0)
        }

        coverImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(140)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
