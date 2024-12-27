import UIKit
import SnapKit
import Then
import ProgressHUD

final class MyNftViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel: MyNFTViewModelProtocol
    private var isLiked: Bool = false
    
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
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        stubLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    private func updateView() {
    }
    
    func applySort(option: String) {
        switch option {
        case "По цене":
            // Сортировка по имени
            print("Сортируем по цене")
        case "По рейтингу":
            // Сортировка по дате
            print("Сортируем по рейтингу")
        case "По названию":
            // Сортировка по цене
            print("Сортируем по названию")
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func backwardButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonDidTap() {
        Logger.log("tap sort button")
        
        let sortOptions = [String(localizable: .sortPrice),
                           String(localizable: .sortRating),
                           String(localizable: .sortNftName)]
        
        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: sortOptions) { selectedOption in
                // Обработка выбранной опции
                Logger.log("Выбранный вариант сортировки: \(selectedOption)")
                self.applySort(option: selectedOption)
            }
    }
}

// MARK: - UITableViewDataSource
extension MyNftViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NftTableViewCell",
                                                       for: indexPath) as? NftTableViewCell else {
                    return UITableViewCell()
                }
//        // Конфигурируем ячейку с нужными данными
//        let nft = Nft
        cell.setText("Test test")
//        cell.setImage(.stabcart)
        cell.setAuthor("Test Test")
        cell.setPrice("1.28 ETH")
        cell.setRating(4)
        cell.setLike(false)
        cell.setInCart(false)
        
        cell.configure(
           with: .myNft,
            onLike: { [weak self] in
                guard let self = self else { return }
                self.isLiked.toggle()
                cell.setLike(self.isLiked)
//                print("Like button tapped for \(nft.name)")
                // Обновить модель данных
            },
           onCart: {})
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
