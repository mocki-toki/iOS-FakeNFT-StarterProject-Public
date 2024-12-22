import UIKit
import SnapKit
import Then

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: ProfileViewViewModelType?
    let servicesAssembly: ServicesAssembly
    
    // MARK: - UI components
    
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
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
    
    // MARK: - UITableView
    
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.register(ProfileLinkTableViewCell.self, forCellReuseIdentifier: "ProfileCell")
    }
    
    // MARK: - Initialization
    
    init(viewModel: ProfileViewModel = ProfileViewModel(), servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
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
        
        setupNavBar()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Navigation
    
    private func setupNavBar() {
        let editButton = UIBarButtonItem(
            image: UIImage(named: "Edit"),
            style: .plain,
            target: self,
            action: #selector(editButtonDidTapped)
        )
        editButton.tintColor = UIColor.closeButton
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        guard let viewModel = viewModel else {return}
        usernameLabel.text = viewModel.username
        bioLabel.text = viewModel.bio
        websiteLink.setTitle(viewModel.website, for: .normal)
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(websiteLink.snp.bottom).offset(40)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Actions
    
    @objc private func editButtonDidTapped() {
        print("Edit Profile button tapped!")

        let editProfileViewController = EditProfileViewController()
        let navController = UINavigationController(rootViewController: editProfileViewController)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func openUserWebsite() {
        guard let viewModel = viewModel else { return }
        
        let webViewModel = WebViewModel(urlString: viewModel.website)
        let webViewController = WebViewController(viewModel: webViewModel)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

    // MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    // Обработка нажатия на ячейку
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
    // настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell",
                                                       for: indexPath) as? ProfileLinkTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none // Отключаем выделение
        let item = viewModel.tableItems[indexPath.row]
        cell.configure(with: item.title, amount: item.count)
        return cell
    }
}
