import UIKit
import SnapKit
import Then
import ProgressHUD

final class MyNftViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel: MyNFTViewModelProtocol
    
    // MARK: - UI components
    
    private lazy var stubLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.text = "У Вас ещё нет NFT"
        $0.textColor = UIColor.textPrimary
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private lazy var backwardButton = UIBarButtonItem().then {
        $0.image = UIImage(named: "Backward")
        $0.style = .plain
        $0.target = self
        $0.action = #selector(backwardButtonDidTap)
        $0.tintColor = UIColor.closeButton
    }
    
    private lazy var sortButton = UIBarButtonItem().then {
        $0.image = UIImage(named: "Sort")
        $0.style = .plain
        $0.target = self
        $0.action = #selector(sortButtonDidTap)
        $0.tintColor = UIColor.closeButton
    }
    
    // MARK: - UITableView
    
    private lazy var tableView = UITableView().then {
        //        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = .yWhite
        $0.register(ProfileLinkTableViewCell.self, forCellReuseIdentifier: "cell")
        //        $0.register(MyNFTTableViewCell.self, forCellReuseIdentifier: MyNFTTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Initializers
    
    init(viewModel: MyNFTViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yWhite
        setupViews()
        setupConstraints()
        
        setupNavigationBar()
    }
    
    // MARK: - Navigation
    
    private func setupNavigationBar() {
        title = "Мои NFT"
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.leftBarButtonItem = backwardButton
        navigationController?.navigationBar.tintColor = .yBlack
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(stubLabel)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        stubLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    private func updateView() {
    }
    
    // MARK: - Actions
    
    @objc private func backwardButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonDidTap() {
        Logger.log("tap sort button")
    }
}

// MARK: - UITableViewDataSource
extension MyNftViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
