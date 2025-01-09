import UIKit
import SnapKit
import Then

final class MyNftViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel: MyNFTViewModelProtocol
    
    // MARK: - UI components
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .gray
    }
    
    private lazy var stubLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.text = String(localizable: .myNFTStub) // У Вас ещё нет NFT
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
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = .yWhite
        $0.register(NftTableViewCell.self, forCellReuseIdentifier: "NftTableViewCell")
    }
    
    // MARK: - Initializers
    
    init(viewModel: MyNFTViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
        self.hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
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

        viewModel.loadNFTs()
    }
    
    // MARK: - Navigation
    
    private func setupNavigationBar() {
        title = String(localizable: .profileLinksMyNfts) // Мои NFT
        navigationItem.leftBarButtonItem = backwardButton
        navigationController?.navigationBar.tintColor = .yBlack
    }
    
    // MARK: - Bind
    private func bindViewModel() {
        viewModel.onLoadingStatusChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.tableView.isHidden = true
                    Logger.log("Loading data...")
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.updateView()
                    self?.viewModel.applySavedSort()
                    Logger.log("Data loaded")
                }
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        view.addSubview(stubLabel)
    }
    
    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        stubLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    private func updateView() {
        DispatchQueue.main.async {
            if self.viewModel.numberOfNFTs() == 0 {
                self.tableView.isHidden = true
                self.stubLabel.isHidden = false
                self.navigationItem.rightBarButtonItem = nil
            } else {
                self.tableView.isHidden = false
                self.stubLabel.isHidden = true
                self.navigationItem.rightBarButtonItem = self.sortButton
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func backwardButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonDidTap() {
        Logger.log("tap sort button")
        
        let sortOptions = viewModel.sortOptions
        
        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: sortOptions) { [weak self] selectedOption in
                Logger.log("Выбранный вариант сортировки: \(selectedOption)")
                self?.viewModel.applySort(option: selectedOption)
                self?.tableView.reloadData()
            }
    }
}

// MARK: - UITableViewDataSource
extension MyNftViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfNFTs()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NftTableViewCell",
                                                       for: indexPath) as? NftTableViewCell,
              let nft = viewModel.getNFT(at: indexPath.row) else {
            Logger.log("Ошибка при создании ячейки")
            return UITableViewCell()
        }
        Logger.log("Создана ячейка NFT \(nft.name)")
        cell.setText(nft.name)
        cell.setAuthor("от \(nft.authorName)")
        cell.setPrice(nft.formattedPrice())
        cell.setRating(nft.rating)
        
        viewModel.loadImage(for: nft) { image in
            DispatchQueue.main.async { 
                if let image = image {
                    cell.setImage(image)
                }
            }
        }
        
        cell.configure(
            with: .myNft,
            onLike: { [weak self] in
                guard let self = self else { return }
                viewModel.isLiked.toggle()
                cell.setLike(viewModel.isLiked)
                print("Like button tapped for \(nft.name)")
            },
            onCart: {})
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
