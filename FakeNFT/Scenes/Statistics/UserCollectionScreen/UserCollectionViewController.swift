import UIKit
import SnapKit
import Then

final class UserCollectionViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: UserCollectionViewModel
    private let loader = UIActivityIndicatorView(style: .large)
    
    let servicesAssembly: ServicesAssembly
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumInteritemSpacing = 9
            $0.minimumLineSpacing = 8
            $0.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    ).then {
        $0.register(NftCollectionViewCell.self)
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.allowsMultipleSelection = false
    }
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly, viewModel: UserCollectionViewModel) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        setupUI()
        bindViewModel()
        showLoader()
        
        viewModel.loadUserNfts()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.hideLoader()
        }
        viewModel.onErrorOccurred = { [weak self] message, retryAction in
            guard let self = self else { return }
            self.hideLoader()
            self.showErrorAlert(message: message, retryAction: retryAction)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .yWhite
        setupNavigationBar()
        setupLoader()
        
        collectionView.showsVerticalScrollIndicator = true
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(108)
            make.left.equalTo(view)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupNavigationBar() {
        title = String(localizable: .statisticsCollection)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .yBlack
        navigationItem.leftBarButtonItem?.tintColor = .yBlack
    }
    
    private func setupLoader() {
        view.addSubview(loader)
        loader.hidesWhenStopped = true
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Loader Methods
    private func showLoader() {
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
    }
    
    private func hideLoader() {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
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
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension UserCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNfts().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "NftCollectionViewCell", for: indexPath)
                as? NftCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let nft = viewModel.getNfts()[indexPath.item]
        cell.configure(
            with: .collection,
            onLike: {
                self.viewModel.toggleLikeNft(byId: nft.id)
            },
            onCart: {
                self.viewModel.toggleCartNft(byId: nft.id)
            }
        )

            if let url = URL(string: nft.images[0]) {
                
            cell.setImage(url)
            }

        cell.setRating(nft.rating)
        cell.setPrice("\(nft.price) ETH")
        cell.setText(nft.name)

        let nftStates = viewModel.getAdditions()
        cell.setLike(nftStates[nft.id]?.isLiked ?? false)
        cell.setInCart(nftStates[nft.id]?.isInCart ?? false)
        return cell
    }
}

// MARK: - CollectionView DelegateFlowLayout
extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 108
        let height: CGFloat = 192
        return CGSize(width: width, height: height)
    }
}
