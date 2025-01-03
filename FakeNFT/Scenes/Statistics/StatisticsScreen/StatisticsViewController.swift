import UIKit
import SnapKit
import Then

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    let servicesAssembly: ServicesAssembly

    private let viewModel: StatisticsViewModel
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly, viewModel: StatisticsViewModel? = nil) {
        self.servicesAssembly = servicesAssembly
        let nftService = servicesAssembly.nftService
        let userService = servicesAssembly.userService
        self.viewModel = viewModel ?? StatisticsViewModel(nftService: nftService, userService: userService)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.backgroundColor = .yWhiteUniversal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadUsers()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onErrorOccurred = { [weak self] message, retryAction in
            guard let self = self else { return }
            self.showErrorAlert(message: message, retryAction: retryAction)
        }
    }
    
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            image: UIImage(named: "Sort"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = .yBlack
        navigationItem.rightBarButtonItem = sortButton
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(108)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Actions
    @objc private func sortButtonTapped() {
        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: [String(localizable: .sortUserName), String(localizable: .sortRating)]
        ) { [weak self] selectedOption in
            guard let self = self else { return }
            if selectedOption == String(localizable: .sortUserName) {
                viewModel.sortedUsers(.byName)
            } else if selectedOption == String(localizable: .sortRating) {
                viewModel.sortedUsers(.byRate)
            }
        }
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
        present(alert, animated: true, completion: nil)
    }
    
    private func openUserProfile(for userId: String) {
        navigationItem.backButtonTitle = ""
        self.hidesBottomBarWhenPushed = true
        
        guard let user = viewModel.users.first(where: { $0.id == userId }) else {
            print("User not found")
            return
        }
        
        let userCardViewModel = UserCardViewModel(
            userId: userId,
            userService: servicesAssembly.userService,
            website: user.website)
        let userCardViewController = UserCardViewController(servicesAssembly: servicesAssembly, viewModel: userCardViewModel)
        navigationController?.pushViewController(userCardViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user, rank: indexPath.row + 1)
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.users[indexPath.row]
        openUserProfile(for: selectedUser.id)
    }
}
