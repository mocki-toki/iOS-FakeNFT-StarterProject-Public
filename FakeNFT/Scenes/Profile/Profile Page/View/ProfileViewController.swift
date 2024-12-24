import UIKit
import SnapKit
import Then
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: ProfileViewViewModelType?
    let servicesAssembly: ServicesAssembly
    
    // MARK: - UI components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .gray
    }
    
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
        $0.image = UIImage(named: "AvatarStub")
    }
    
    lazy var usernameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.bold22
        $0.textColor = UIColor.textPrimary
    }
    
    private lazy var bioLabel = UILabel().then {
        $0.font = UIFont.regular13
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.textColor = UIColor.textPrimary
    }
    
    private lazy var websiteLink = UIButton(type: .system).then {
        $0.titleLabel?.font = UIFont.regular15
        $0.titleLabel?.textColor = UIColor.primary
        $0.addTarget(self, action: #selector(openUserWebsite), for: .touchUpInside)
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
    
    private lazy var editButton = UIBarButtonItem().then {
        $0.image = UIImage(named: "Edit")
        $0.style = .plain
        $0.target = self
        $0.action = #selector(editButtonDidTapped)
        $0.tintColor = UIColor.closeButton
    }
    
    // MARK: - UITableView
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = .yWhite
        $0.register(ProfileLinkTableViewCell.self, forCellReuseIdentifier: "ProfileCell")
    }
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.viewModel = ProfileViewModel(profileNetworkService: servicesAssembly.profileNetworkService)
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
        guard let viewModel = viewModel else { return }
        setupNavBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.loadData()
    }
    
    // MARK: - Navigation
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        guard var viewModel = viewModel else { return }
        
        viewModel.onProfileDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateUI()
            }
        }
        
        viewModel.onLoadingStatusChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateLoadingIndicator(isLoading)
            }
        }
    }
    private var currentAvatarURL: URL?
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        let profile = viewModel.userProfile
        guard let profile = profile else { return }
        DispatchQueue.main.async {
            self.usernameLabel.text = profile.name
            self.bioLabel.text = profile.description
            self.websiteLink.setTitle(profile.website, for: .normal)
            if let avatarURL = URL(string: profile.avatar) {
                self.avatarImageView.kf.setImage(with: avatarURL,
                                                 placeholder: UIImage(named: "AvatarStub"),
                                                 options: [.cacheOriginalImage],
                                                 progressBlock: nil,
                                                 completionHandler: { result in
                    switch result {
                    case .success(let value):
                        Logger.log("Image successfully loaded: \(value.source.url?.absoluteString ?? "")", level: .debug)
                    case .failure(let error):
                        Logger.log("Error loading image: \(error.localizedDescription)", level: .error)
                    }
                })
            } else {
                Logger.log("Уже загружено \(profile.avatar)", level: .warning)
            }
            self.tableView.reloadData()
        }
    }
    
    private func updateLoadingIndicator(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            tableView.isUserInteractionEnabled = false
            editButton.isEnabled = false
            Logger.log("Loading data...")
        } else {
            activityIndicator.stopAnimating()
            tableView.isUserInteractionEnabled = true
            editButton.isEnabled = true
            Logger.log("Data loaded")
        }
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        avatarStackView.addArrangedSubview(avatarImageView)
        avatarStackView.addArrangedSubview(usernameLabel)
        profileStackView.addArrangedSubview(avatarStackView)
        profileStackView.addArrangedSubview(bioLabel)
        view.addSubview(profileStackView)
        view.addSubview(websiteLink)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(websiteLink.snp.bottom).offset(40)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonDidTapped() {
        Logger.log("Edit Profile button tapped!")
        guard let profile = viewModel?.userProfile else { return }
        let editProfileViewModel = EditProfileViewModel(profile: profile)
        let editProfileViewController = EditProfileViewController(viewModel: editProfileViewModel)
        
        editProfileViewModel.onProfileUpdated = { [weak self] updatedProfile in
            DispatchQueue.main.async {
                self?.viewModel?.userProfile = updatedProfile
            }
        }
        
        let navController = UINavigationController(rootViewController: editProfileViewController)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func openUserWebsite() {
        guard let viewModel = viewModel,
              let website = viewModel.userProfile?.website else { return }
        
        let webViewModel = WebViewModel(urlString: website)
        let webViewController = WebViewController(viewModel: webViewModel)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let selectedItem = viewModel.tableItems[indexPath.row]
        navigationController?.pushViewController(selectedItem.destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 3 }
        return viewModel.tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell",
                                                       for: indexPath) as? ProfileLinkTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let item = viewModel.tableItems[indexPath.row]
        cell.configure(with: item.title, amount: item.count)
        return cell
    }
}
