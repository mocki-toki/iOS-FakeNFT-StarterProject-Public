import UIKit
import SnapKit
import Then

final class CartViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let footerView = UIView()
    private let itemCountLabel = UILabel()
    private let totalPriceLabel = UILabel()
    private let checkoutButton = UIButton()
    private let footerContent = UIView()
    private let emptyStateLabel = UILabel()
    private let viewModel: CartViewModel
    
    // MARK: - Public Properties
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Initializer
    init(servicesAssembly: ServicesAssembly, viewModel: CartViewModel) {
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
        Logger.log("CartViewController loaded")
        setupView()
        setupBindings()
        updateFooter()
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .yWhite
        setupCommonViews()
        setupConstraints()
        updateUI(for: viewModel.isCartEmpty)
    }
    
    private func setupCommonViews() {
        view.addSubview(tableView)
        view.addSubview(footerView)
        view.addSubview(emptyStateLabel)
        
        setupTableView()
        setupFooterView()
        setupEmptyStateLabel()
    }
    
    private func updateUI(for isCartEmpty: Bool) {
        Logger.log(isCartEmpty ? "Cart is empty" : "Cart has items")
        emptyStateLabel.isHidden = !isCartEmpty
        tableView.isHidden = isCartEmpty
        footerView.isHidden = isCartEmpty
        navigationController?.navigationBar.isHidden = isCartEmpty
    }
    
    private func setupNavigationBar() {
        let hamburgerButton = UIBarButtonItem().then {
            $0.image = .sort
            $0.style = .plain
            $0.target = self
            $0.action = #selector(hamburgerButtonTapped)
            $0.tintColor = .yBlack
        }
        navigationItem.rightBarButtonItem = hamburgerButton
    }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel.do {
            $0.text = String(localizable: .cartEmpty)
            $0.textColor = .yBlack
            $0.font = .bold17
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupTableView() {
        tableView.register(NftTableViewCell.self, forCellReuseIdentifier: "NftTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupFooterView() {
        footerView.do {
            $0.backgroundColor = .yLightGrey
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        footerView.addSubview(footerContent)
        setupFooterComponents()
    }
    
    private func setupFooterComponents() {
        footerContent.addSubview(itemCountLabel)
        footerContent.addSubview(totalPriceLabel)
        footerContent.addSubview(checkoutButton)
        
        itemCountLabel.do {
            $0.font = .regular15
            $0.textColor = .yBlack
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        totalPriceLabel.do {
            $0.font = .bold17
            $0.textColor = .yGreenUniversal
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        checkoutButton.do {
            $0.setTitle(String(localizable: .cartToPay), for: .normal)
            $0.backgroundColor = .yBlack
            $0.tintColor = .yWhite
            $0.titleLabel?.font = .bold17
            $0.layer.cornerRadius = 8
            $0.addTarget(self, action: #selector(handleCheckout), for: .touchUpInside)
        }
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).inset(-5)
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(76)
        }
        
        footerContent.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        totalPriceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(itemCountLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(totalPriceLabel.snp.trailing).offset(24)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    private func setupBindings() {
        viewModel.onCartUpdated = { [weak self] in
            guard let self = self else { return }
            Logger.log("Cart updated: \(self.viewModel.numberOfItems()) items, total \(self.viewModel.formattedTotalCost)")
            self.tableView.reloadData()
            self.updateFooter()
            self.updateUI(for: self.viewModel.isCartEmpty)
        }
    }
    
    private func updateFooter() {
        itemCountLabel.text = viewModel.formattedTotalItems
        totalPriceLabel.text = viewModel.formattedTotalCost
    }
    
    private func presentDeleteConfirmation(for item: CartItem) {
        Logger.log("User initiated deletion for item: \(item.name)")
        let viewModel = DeleteConfirmationViewModel(
            nftImage: item.image,
            message: String(localizable: .cartDeleteConfirmation),
            onConfirm: { [weak self] in
                self?.viewModel.removeItem(item)
                Logger.log("User confirmed deletion for item: \(item.name)", level: .debug)
            },
            onCancel: {
                Logger.log("User canceled deletion for item: \(item.name)", level: .debug)
            }
        )
        let confirmationVC = DeleteConfirmationViewController(viewModel: viewModel)
        confirmationVC.modalPresentationStyle = .overFullScreen
        present(confirmationVC, animated: true, completion: nil)
    }
    
    @objc private func handleCheckout() {
        Logger.log("Checkout initiated with \(viewModel.numberOfItems()) items totaling \(viewModel.formattedTotalCost)")
        let paymentVC = PaymentSelectionViewController(cartViewModel: viewModel)
        paymentVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    @objc private func hamburgerButtonTapped() {
        Logger.log("Hamburger button tapped", level: .debug)
        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: [
                String(localizable: .sortPrice),
                String(localizable: .sortRating),
                String(localizable: .sortNftName)
            ]) { [weak self] selectedOption in
                self?.viewModel.sortItems(by: selectedOption)
                Logger.log("User sorted list of items by \(selectedOption)")
            }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NftTableViewCell",
            for: indexPath
        ) as? NftTableViewCell else {
            Logger.log("Failed to dequeue NftTableViewCell at index \(indexPath.row)", level: .error)
            return UITableViewCell()
        }
        
        let item = viewModel.item(at: indexPath.row)
        Logger.log("Configuring cell for item: \(item.name) at index \(indexPath.row)", level: .debug)
        cell.configure(
            with: .cart,
            onLike: {},
            onCart: { [weak self] in
                self?.presentDeleteConfirmation(for: item)
            })
        setValuesToCell(cell, item)
        
        return cell
    }
    
    func setValuesToCell(_ cell: NftTableViewCell, _ item: CartItem) {
        cell.setText(item.name)
        cell.setImage(item.image)
        cell.setPrice("\(item.price) ETH")
        cell.setRating(item.rating)
        cell.setInCart(item.isInCart)
        cell.setPriceCaption(String(localizable: .cartPrice))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
