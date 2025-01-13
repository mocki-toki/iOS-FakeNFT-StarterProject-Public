import UIKit
import Combine
import SnapKit
import Then

final class PaymentSelectionViewController: UIViewController {
    private let viewModel: PaymentSelectionViewModel
    private let cartViewModel: CartViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let agreementURL = URL(string: "https://yandex.ru/legal/practicum_termsofuse")
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout().then {
            let sideInset: CGFloat = 16
            let interItemSpacing: CGFloat = 7
            let lineSpacing: CGFloat = 7
            let availableWidth = UIScreen.main.bounds.width - sideInset * 2 - interItemSpacing
            let itemWidth = availableWidth / 2
            let itemHeight: CGFloat = 46
            
            $0.itemSize = CGSize(width: itemWidth, height: itemHeight)
            $0.minimumLineSpacing = lineSpacing
            $0.minimumInteritemSpacing = interItemSpacing
            $0.sectionInset = UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: sideInset)
        }
        return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(PaymentCell.self, forCellWithReuseIdentifier: PaymentCell.identifier)
            $0.backgroundColor = .yWhite
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    private lazy var bottomContainerView: UIView = UIView().then {
        $0.backgroundColor = .yLightGrey
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.addSubview(agreementContainerView)
        $0.addSubview(payButton)
        
        agreementContainerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
        }
        
        payButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(agreementContainerView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
        }
    }
    
    private lazy var agreementContainerView: UIView = UIView().then {
        $0.addSubview(agreementLabel)
        $0.addSubview(agreementLinkButton)
        
        agreementLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        agreementLinkButton.snp.makeConstraints { make in
            make.top.equalTo(agreementLabel.snp.bottom).offset(4)
            make.leading.equalTo(agreementLabel.snp.leading)
            make.trailing.bottom.equalToSuperview()
        }
    }
    
    private lazy var agreementLabel: UILabel = UILabel().then {
        $0.text = String(localizable: .paymentAgreementText)
        $0.font = .regular13
        $0.textColor = .yBlack
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    private lazy var agreementLinkButton: UIButton = UIButton(type: .system).then {
        $0.setTitle(String(localizable: .paymentAgreementLink), for: .normal)
        $0.titleLabel?.font = .regular13
        $0.setTitleColor(.yBlueUniversal, for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.addTarget(self, action: #selector(agreementLinkTapped), for: .touchUpInside)
    }
    
    private lazy var payButton: PrimaryButton = PrimaryButton(
        title: String(localizable: .paymentButtonTitle)).then {
            $0.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        }
    
    private lazy var loader: UIActivityIndicatorView = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .yBlack
    }
    
    init(cartViewModel: CartViewModel, currenciesService: CurrenciesService) {
        self.cartViewModel = cartViewModel
        self.viewModel = PaymentSelectionViewModel(currenciesService: currenciesService)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .yWhite
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        view.addSubview(loader)
        
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        title = String(localizable: .paymentTitle)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .yBlack
        navigationItem.leftBarButtonItem?.tintColor = .yBlack
    }
    
    private func setupBindings() {
        viewModel.$paymentMethods
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$selectedMethod
            .sink { selectedMethod in
                Logger.log("Selected Method: \(selectedMethod?.title ?? "None")")
            }
            .store(in: &subscriptions)
        
        cartViewModel.$isCartClearedAfterPayment
            .receive(on: RunLoop.main)
            .sink { [weak self] isCleared in
                if isCleared {
                    self?.showSuccessScreen()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$selectedMethod
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedMethod in
                self?.updatePayButtonState(isEnabled: selectedMethod != nil)
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loader.startAnimating()
                } else {
                    self.loader.stopAnimating()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$fetchPaymentMethodsResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let result = result else { return }
                self?.handleFetchPaymentMethodsResult(result)
            }
            .store(in: &subscriptions)
        
        viewModel.$setCurrencyResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let result = result else { return }
                self?.handleSetCurrencyResult(result)
            }
            .store(in: &subscriptions)
        
        viewModel.$shouldCloseScreen
            .receive(on: RunLoop.main)
            .sink { [weak self] shouldClose in
                if shouldClose {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func payButtonTapped() {
        Logger.log("Pay button tapped")
        viewModel.processPayment()
        cartViewModel.clearCartAfterPayment()
    }
    
    @objc private func agreementLinkTapped() {
        guard let url = agreementURL else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: String(localizable: .agreementsGoBackTitle),
            style: .plain,
            target: nil,
            action: nil
        )
        let webVC = WebViewController(url: url)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    private func showSuccessScreen() {
        let successVC = SuccessViewController()
        successVC.modalPresentationStyle = .fullScreen
        successVC.onDismiss = { [weak self] in
            self?.cartViewModel.clearCart()
        }
        present(successVC, animated: true, completion: nil)
    }
    
    private func handleFetchPaymentMethodsResult(_ result: PaymentSelectionViewModel.FetchPaymentMethodsResult) {
        switch result {
        case .success:
            Logger.log("Payment methods were received")
        case .failure:
            AlertPresenter.presentAlert(
                on: self,
                title: String(localizable: .errorNetwork),
                message: nil,
                buttons: [
                    AlertPresenter.Button(
                        title: String(localizable: .errorCancel),
                        action: { [weak self] in
                            self?.viewModel.processOpeningCartView()
                        },
                        style: .default,
                        isPreferred: false
                    ),
                    AlertPresenter.Button(
                        title: String(localizable: .errorRepeat),
                        action: { [weak self] in
                            self?.viewModel.loadPaymentMethods()
                        },
                        style: .default,
                        isPreferred: true
                    )
                ]
            )
        }
    }
    
    private func handleSetCurrencyResult(_ result: PaymentSelectionViewModel.SetCurrencyResult) {
        switch result {
        case .success:
            Logger.log("Currency has been set for the order")
            showSuccessScreen()
        case .failure:
            AlertPresenter.presentAlert(
                on: self,
                title: String(localizable: .paymentFail),
                message: nil,
                buttons: [
                    AlertPresenter.Button(
                        title: String(localizable: .errorCancel),
                        action: nil,
                        style: .default,
                        isPreferred: false
                    ),
                    AlertPresenter.Button(
                        title: String(localizable: .errorRepeat),
                        action: { [weak self] in
                            self?.viewModel.processPayment()
                        },
                        style: .default,
                        isPreferred: true
                    )
                ]
            )
        }
    }
    
    private func updatePayButtonState(isEnabled: Bool) {
        payButton.isEnabled = isEnabled
        payButton.backgroundColor = isEnabled ? .yBlack : .yGreyUniversal
    }
}

extension PaymentSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.paymentMethods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaymentCell.identifier, for: indexPath
        ) as? PaymentCell else {
            return UICollectionViewCell()
        }
        let method = viewModel.paymentMethods[indexPath.item]
        cell.configure(with: method)
        return cell
    }
}

extension PaymentSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPaymentMethod(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        Logger.log("Deselected method at index: \(indexPath.item)")
    }
}
