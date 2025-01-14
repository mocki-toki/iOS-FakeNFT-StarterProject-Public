import UIKit
import SnapKit
import Then

final class ProfileLinkTableViewCell: UITableViewCell {
    // MARK: - Properties
    private lazy var arrowImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Forward")
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.textColor = UIColor.textPrimary
    }
    
    private lazy var amountNftLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.textColor = UIColor.textPrimary
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .yWhite
        contentView.addSubview(arrowImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountNftLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(16)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        amountNftLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).inset(16)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(14)
        }
    }
    
    // MARK: - configure
    
    func configure(with title: String, amount: Int?) {
        titleLabel.text = title
        if amount == nil {
            amountNftLabel.text = nil
        } else {
                guard let amount = amount else { return }
            amountNftLabel.text = "(\(amount))"
        }
    }
}
