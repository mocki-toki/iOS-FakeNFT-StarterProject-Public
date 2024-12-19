import UIKit
import SnapKit
import Then

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    let servicesAssembly: ServicesAssembly

    private let viewModel: StatisticsViewModel
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    private let sortButton = UIButton().then {
        $0.setImage(UIImage(named: "Sort"), for: .normal)
        $0.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly, viewModel: StatisticsViewModel? = nil) {
        self.servicesAssembly = servicesAssembly
        let nftService = servicesAssembly.nftService
        self.viewModel = viewModel ?? StatisticsViewModel(nftService: nftService)
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
        viewModel.loadUsers()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(108)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(46)
            make.left.equalTo(view.snp.right).offset(-50)
            make.width.height.equalTo(42)
        }
    }
    
    // MARK: - Actions
    @objc private func sortButtonTapped() {
        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: [String(localizable: .sortName), String(localizable: .sortRating)]
        ) { selectedOption in
            print("Selected option: \(selectedOption)")
        }
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
        cell.configure(with: user)
        return cell
    }
}
