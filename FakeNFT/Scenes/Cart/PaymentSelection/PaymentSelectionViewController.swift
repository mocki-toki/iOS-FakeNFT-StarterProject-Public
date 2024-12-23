import UIKit
import Combine
import SnapKit
import Then

final class PaymentSelectionViewController: UIViewController {
    private let viewModel = PaymentSelectionViewModel()
    private let cartViewModel: CartViewModel
    private var subscriptions = Set<AnyCancellable>()
    
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
            $0.backgroundColor = .white
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    private lazy var bottomContainerView: UIView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
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
    
    init(cartViewModel: CartViewModel) {
        self.cartViewModel = cartViewModel
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
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
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
        navigationController?.navigationBar.tintColor = .black
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
        
        viewModel.$paymentResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let result = result else { return }
                self?.handlePaymentResult(result)
            }
            .store(in: &subscriptions)
        
        viewModel.$selectedMethod
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedMethod in
                self?.updatePayButtonState(isEnabled: selectedMethod != nil)
            }
            .store(in: &subscriptions)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func payButtonTapped() {
        Logger.log("Pay button tapped")
        viewModel.processPayment()
    }
    
    @objc private func agreementLinkTapped() {
        if let url = URL(string: "https://en.wikipedia.org/wiki/End-user_license_agreement") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showSuccessScreen() {
        let successVC = SuccessViewController()
        successVC.modalPresentationStyle = .fullScreen
        successVC.onDismiss = { [weak self] in
            self?.cartViewModel.clearCart()
        }
        present(successVC, animated: true, completion: nil)
    }
    
    private func handlePaymentResult(_ result: PaymentSelectionViewModel.PaymentResult) {
        switch result {
        case .success:
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
