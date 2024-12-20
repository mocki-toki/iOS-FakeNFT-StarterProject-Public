import UIKit
import SnapKit
import Then

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    let servicesAssembly: ServicesAssembly
    
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    lazy var usernameLabel = UILabel().then {
        $0.text = "Joaquin Phoenix"
        $0.textAlignment = .left
        $0.font = UIFont.bold22
        $0.textColor = UIColor.textPrimary
    }
    
    private lazy var bioLabel = UILabel().then {
        $0.text = """
                    Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.
                    """
        $0.font = UIFont.regular13
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.textColor = UIColor.textPrimary
    }
    
    private lazy var websiteLink = UIButton(type: .system).then {
        $0.setTitle("www.mysite.com", for: .normal)
        $0.titleLabel?.font = UIFont.regular15
        $0.titleLabel?.textColor = UIColor.primary
        //        $0.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
    }
    
    private lazy var avatarStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .leading
        $0.distribution = .equalSpacing
    }
    
    private lazy var profileStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .leading
        $0.distribution = .equalSpacing
    }
    // MARK: - UITableView

    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yWhite
        
        setupViews()
        setupConstraints()
    }
    // MARK: - UI Setup
    private func setupViews() {
        avatarStackView.addArrangedSubview(avatarImageView)
        avatarStackView.addArrangedSubview(usernameLabel)
        profileStackView.addArrangedSubview(avatarStackView)
        profileStackView.addArrangedSubview(bioLabel)
        view.addSubview(profileStackView)
        view.addSubview(websiteLink)
        //        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
        }
        
        websiteLink.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.top.equalTo(profileStackView.snp.bottom).offset(8)
            make.left.equalTo(profileStackView.snp.left)
        }
    }
    
    // MARK: - Actions
}
