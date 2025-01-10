import UIKit

final class FavoritesViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel: FavoritesViewModelProtocol
    
    // MARK: - UI components
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .gray
    }
    
    private lazy var stubLabel = UILabel().then {
        $0.font = UIFont.bold17
        $0.text = String(localizable: .favoritesStub) // У Вас ещё нет избранных NFT
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
    
    // MARK: - UICollectionView
    
    private lazy var collectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = ($0.collectionViewLayout as? UICollectionViewFlowLayout) ?? UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.scrollDirection = .vertical
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .yWhite
        $0.register(NftCollectionViewCell.self, forCellWithReuseIdentifier: "NftCollectionViewCell")
    }
    
    // MARK: - Initializers
    
    init(viewModel: FavoritesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
    }
    
    // MARK: - Navigation
    private func setupNavigationBar() {
        title = String(localizable: .profileLinksFavorites) // Избранные NFT
        navigationItem.leftBarButtonItem = backwardButton
        navigationController?.navigationBar.tintColor = .yBlack
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.addSubview(activityIndicator)
        view.addSubview(collectionView)
        view.addSubview(stubLabel)
    }
    
    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        stubLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backwardButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nft = Nft(
            createdAt: "2025-01-10T12:00:00Z",
            name: "Olive Avila",
            images: [
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/1.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/2.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/3.png"
            ],
            rating: 2,
            description: "saepe patrioque recteque doming fabellas harum libero",
            price: 21.0,
            author: "https://amazing_cerf.fakenfts.org/",
            id: "28829968-8639-4e08-8853-2f30fcf09783"
        )
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NftCollectionViewCell",
            for: indexPath) as? NftCollectionViewCell else {
            Logger.log("Ошибка при создании ячейки")
            return UICollectionViewCell()
        }
        Logger.log("Создана ячейка NFT \(nft.name)")
        cell.setText(nft.name)
        cell.setAuthor("от \(nft.authorName)")
        cell.setPrice(nft.formattedPrice())
        cell.setRating(nft.rating)
        
        if let imageUrl = URL(string: nft.images.first ?? "") {
            cell.setImage(imageUrl)
        }
        
        cell.configure(
            with: .favorite,
            onLike: { [weak self] in
                guard let self = self else { return }
                viewModel.isLiked.toggle()
                cell.setLike(viewModel.isLiked)
                print("Like button tapped for \(nft.name)")
            },
            onCart: {})
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = 168
        let itemHeight = 80
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    // отступы от краев экрана
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
    
    //  расстояние между строками (вертикальный отступ)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // расстояние между ячейками в строке (горизонтальный отступ)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7 // Отступ между колонками
    }
}
