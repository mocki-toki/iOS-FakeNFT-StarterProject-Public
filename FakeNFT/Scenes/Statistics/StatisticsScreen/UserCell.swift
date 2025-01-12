import UIKit
import SnapKit
import Then

final class UserCell: UITableViewCell {
    static let identifier = "UserCell"
    
    // MARK: - Subviews
    private lazy var cartView = UIImageView().then {
        $0.backgroundColor = .yLightGrey
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var rankLabel = UILabel().then {
        $0.font = UIFont.regular15
        $0.textColor = .yBlack
        $0.textAlignment = .center
    }
    
    private lazy var avatarImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 14
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.font = UIFont.bold22
        $0.textColor = .yBlack
    }
    
    private lazy var nftCountLabel = UILabel().then {
        $0.font = UIFont.bold22
        $0.textColor = .yBlack
        $0.textAlignment = .center
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(rankLabel)
        rankLabel.snp.makeConstraints { make in
            make.width.equalTo(27)
            make.height.equalTo(20)
            make.leading.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(28)
        }
        
        addSubview(cartView)
        cartView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.leading.equalTo(cartView.snp.leading).offset(16)
            make.top.equalTo(cartView.snp.top).offset(26)
        }
        
        addSubview(nftCountLabel)
        nftCountLabel.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(28)
            make.trailing.equalTo(cartView.snp.trailing).offset(-16)
            make.top.equalTo(cartView.snp.top).offset(26)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.equalTo(nftCountLabel.snp.leading).offset(-16)
            make.top.equalTo(cartView.snp.top).offset(26)
            make.bottom.equalTo(cartView.snp.bottom).offset(-26)
        }
    }
    
    func configure(with user: Users, rank: Int) {
        rankLabel.text = "\(rank)"
        avatarImageView.kf.setImage(with: URL(string: user.avatar), placeholder: UIImage(named: "AvatarStub"))
        nameLabel.text = user.name
        nftCountLabel.text = "\(user.nfts.count)"
    }
}
