import UIKit
import SnapKit
import Then

final class UserCardViewController: UIViewController {
    // MARK: - Properties
    let servicesAssembly: ServicesAssembly
    
    private let viewModel: UserCardViewModel
    
    private lazy var profileStackView = UIStackView().then {
        $0.distribution = .fill
        $0.axis = .vertical
        $0.spacing = CGFloat(20)
    }
    
    private lazy var avatarNameStackView = UIStackView().then {
        $0.distribution = .fill
        $0.axis = .horizontal
        $0.spacing = CGFloat(16)
    }
    
    private lazy var avatarImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 35
    }
    
    private lazy var usernameLabel = UILabel().then {
        $0.font = UIFont.bold22
        $0.textColor = .yBlackUniversal
    }
    
    private lazy var descriptionTextView = UITextView().then {
        $0.font = UIFont.regular13
        $0.textColor = .yBlackUniversal
    }
    
    private lazy var websiteButton = UIButton(type: .system).then {
        $0.setTitle(String(localizable: .buttonWebsite), for: .normal)
        $0.setTitleColor(.yBlackUniversal, for: .normal)
        $0.titleLabel?.font = UIFont.regular15
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
    }
    
    private lazy var collectionLabel = UILabel().then {
        $0.textColor = .yBlackUniversal
        $0.font = UIFont.bold17
    }
    
    private lazy var collectionImage = UIImageView().then {
        $0.image = UIImage(named: "Forward")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var collectionStackView = UIStackView().then {
        $0.distribution = .equalSpacing
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly, viewModel: UserCardViewModel) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self, let user = self.viewModel.user else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.avatar), placeholder: UIImage(named: "AvatarStub"))
            self.usernameLabel.text = user.name
            self.descriptionTextView.text = user.description
            self.collectionLabel.text = "\(String(localizable: .buttonCollection)) (\(user.nfts.count))"
        }
        
        viewModel.onErrorOccurred = { [weak self] message, retryAction in
            guard let self = self else { return }
            self.showErrorAlert(message: message, retryAction: retryAction)
        }
    }
    
    
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        
        view.addSubview(profileStackView)
        view.addSubview(websiteButton)
        view.addSubview(collectionStackView)
        
        avatarNameStackView.addArrangedSubview(avatarImageView)
        avatarNameStackView.addArrangedSubview(usernameLabel)
        
        profileStackView.addArrangedSubview(avatarNameStackView)
        profileStackView.addArrangedSubview(descriptionTextView)
        
        collectionStackView.addArrangedSubview(collectionLabel)
        collectionStackView.addArrangedSubview(collectionImage)
        
        collectionStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.top.equalTo(websiteButton.snp.bottom).offset(40)
            make.height.equalTo(54)
        }
        
        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(162)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
        }
        
        collectionImage.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
        
        websiteButton.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(40)
        }
    }
    
    private func setupNavigationBar() {
        let backImage = UIImage(named: "Backward")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
    }
    
    // MARK: - Actions
    @objc private func openWebsite() {
        navigationItem.backButtonTitle = ""

        guard let websiteURL = URL(string: viewModel.website) else {
            print("Invalid URL")
            return
        }
        
        let webViewController = WebViewController(url: websiteURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: - Methods
    private func showErrorAlert(message: String, retryAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: String(localizable: .alertError),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localizable: .alertRetry), style: .default) { _ in
            retryAction()
        })
        alert.addAction(UIAlertAction(title: String(localizable: .alertCancel), style: .cancel, handler: nil))
    }
}
