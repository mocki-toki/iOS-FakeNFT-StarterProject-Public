import Kingfisher
import SafariServices
import UIKit

protocol NftDetailsView: AnyObject, ErrorView, LoadingView {
    func displayNftDetails(_ nftDetails: NftDetailsModel)
}

final class NftDetailsViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    
    private var viewModel: NftDetailsViewModel
    private let detailsAssembly: NftDetailsAssembly
    
    private lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.backgroundColor = .yWhite
    }
    
    private lazy var contentView = UIView().then {
        $0.backgroundColor = .yWhite
    }
    
    private lazy var likeButton = LikeButton().then {
        $0.setDefaultColor(.yGreyUniversal)
        $0.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var imagesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private lazy var pageControl = LinePageControl()
    
    private lazy var nameLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .bold22
    }
    
    private lazy var ratingView = RatingView()
    
    private lazy var collectionNameLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .bold17
    }
    
    private lazy var priceCaptionLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .regular15
        $0.text = String(localizable: .nftDetailsPriceCaption)
    }
    
    private lazy var priceLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .bold17
    }
    
    private lazy var cartButton = AppButton().then {
        $0.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
    }
    
    private lazy var currenciesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .yLightGrey
        collectionView.layer.cornerRadius = 12
        collectionView.layer.masksToBounds = true
        
        collectionView.register(
            NftDetailsCurrencyCollectionCell.self
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var authorWebsiteButton = AppButton().then {
        $0.setStyle(AppButtonStyle.secondary)
        $0.setTitle(String(localizable: .nftDetailsOpenAuthorSite), for: .normal)
        $0.addTarget(self, action: #selector(authorWebsiteButtonTapped), for: .touchUpInside)
    }
    
    private lazy var otherNftsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.register(NftCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    lazy var activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Lifecycle
    
    init(viewModel: NftDetailsViewModel, detailsAssembly: NftDetailsAssembly) {
        self.viewModel = viewModel
        self.detailsAssembly = detailsAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
        setupNavigationBar()
        
        viewModel.fetchNftDetails()
    }
    
    // MARK: - Private functions
    
    private func setupLayout() {
        view.backgroundColor = .yWhite
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [
            activityIndicator, imagesScrollView,
            pageControl, nameLabel, ratingView, collectionNameLabel,
            priceCaptionLabel, priceLabel, cartButton,
            currenciesCollectionView, authorWebsiteButton, otherNftsCollectionView
        ].forEach { item in
            contentView.addSubview(item)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.height.equalTo(21)
        }
        
        imagesScrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(310)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalTo(imagesScrollView.snp.bottom).offset(12)
            make.height.equalTo(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
        }
        
        ratingView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.top).offset(8)
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }
        
        collectionNameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.top).offset(3)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        priceCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceCaptionLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(16)
        }
        
        cartButton.snp.makeConstraints { make in
            make.top.equalTo(priceCaptionLabel.snp.top)
            make.leading.equalTo(priceLabel.snp.trailing).offset(28)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(220)
            make.height.equalTo(44)
        }
        
        currenciesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(calculateCollectionViewHeight())
        }
        
        authorWebsiteButton.snp.makeConstraints { make in
            make.top.equalTo(currenciesCollectionView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        otherNftsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(authorWebsiteButton.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(192)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func updateCollectionViewHeight() {
        currenciesCollectionView.snp.updateConstraints { make in
            make.height.equalTo(calculateCollectionViewHeight())
        }
    }
    
    private func setupBindings() {
        setupNftDetailsBinding()
        setupNftsBinding()
        setupNftAdditionalsBinding()
    }
    
    private func calculateCollectionViewHeight() -> CGFloat {
        guard let detailsModel = viewModel.detailsModel else { return 0 }
        let itemHeight: CGFloat = 72
        let numberOfItems = CGFloat(detailsModel.currencies.count)

        return itemHeight * numberOfItems
    }
    
    private func setupNftDetailsBinding() {
        viewModel.stateDidChanged = { [weak self] state in
            self?.hideLoading()
            switch state {
            case .data(let collectionDetailsModel):
                self?.displayNftDetails(collectionDetailsModel)
                self?.updateCollectionViewHeight()
            case .failed(let error):
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchNftDetails() }
                )
                self?.showError(errorModel)
            case .loading, .initial:
                self?.showLoading()
            }
        }
    }
    
    private func setupNftsBinding() {
        viewModel.stateOfNftsDidChanged = { [weak self] state in
            switch state {
            case .initial, .loading:
                self?.showLoading()
            case .data:
                self?.hideLoading()
                DispatchQueue.main.async {
                    self?.otherNftsCollectionView.reloadData()
                }
            case .failed(let error):
                self?.hideLoading()
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchNftDetails() }
                )
                self?.showError(errorModel)
            }
        }
    }
    
    private func setupNftAdditionalsBinding() {
        viewModel.stateOfNftAdditionalsDidChanged = { [weak self] state in
            switch state {
            case .initial, .loading:
                self?.showLoading()
                self?.contentView.alpha = 0.5
            case .data:
                guard let self = self else { return }
                
                self.hideLoading()
                self.contentView.alpha = 1
                DispatchQueue.main.async {
                    self.displayNftDetails(self.viewModel.detailsModel!)
                    self.otherNftsCollectionView.reloadData()
                }
            case .failed(let error):
                self?.hideLoading()
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchNftDetails() }
                )
                self?.showError(errorModel)
                self?.contentView.alpha = 1
            }
        }
    }
    
    private func setupNavigationBar() {
        let backImage = UIImage.backward.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage, style: .plain, target: self, action: #selector(backButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.selectedItem = page
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func likeButtonTapped() {
        guard let detailsModel = viewModel.detailsModel else { return }
        viewModel.toggleLikeNft(byId: detailsModel.id)
    }
    
    @objc private func cartButtonTapped() {
        guard let detailsModel = viewModel.detailsModel else { return }
        viewModel.toggleCartNft(byId: detailsModel.id)
    }
    
    @objc private func authorWebsiteButtonTapped() {
        guard let url = viewModel.detailsModel?.authorSiteUrl else {
            print("Invalid URL")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let xOffset = CGFloat(sender.currentPage) * imagesScrollView.bounds.width
        imagesScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
}

// MARK: - CollectionDetailsView

extension NftDetailsViewController: NftDetailsView {
    func displayNftDetails(_ nftDetails: NftDetailsModel) {
        let nftStates = viewModel.cellAdditionalModels
        let isLiked = nftStates[nftDetails.id]?.isLiked ?? false
        let isInCart = nftStates[nftDetails.id]?.isInCart ?? false
        
        likeButton.setLike(isLiked)
        configureImagesScrollView(with: nftDetails.images)
        
        let maxSymbols = 8
        if nftDetails.name.count > maxSymbols {
            nameLabel.text = String(nftDetails.name.prefix(maxSymbols)) + "..."
        } else {
            nameLabel.text = nftDetails.name
        }
        
        ratingView.setRating(nftDetails.rating)
        collectionNameLabel.text = nftDetails.collectionName
        priceLabel.text = "\(nftDetails.price) ETH"
        
        if isInCart {
            cartButton.setStyle(AppButtonStyle.secondary)
            cartButton.setTitle(String(localizable: .nftDetailsInCart), for: .normal)
        } else {
            cartButton.setStyle(AppButtonStyle.primary)
            cartButton.setTitle(String(localizable: .nftDetailsAddToCart), for: .normal)
        }
        
        currenciesCollectionView.reloadData()
    }
    
    private func configureImagesScrollView(with images: [URL]) {
        imagesScrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollViewWidth = imagesScrollView.bounds.width
        let scrollViewHeight = imagesScrollView.bounds.height
        imagesScrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(images.count),
                                              height: scrollViewHeight)
        for (index, imageUrl) in images.enumerated() {
            let xPosition = CGFloat(index) * scrollViewWidth
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            imageView.layer.masksToBounds = true
            
            imageView.kf.setImage(with: imageUrl)
            
            imageView.frame = CGRect(x: xPosition,
                                     y: 0,
                                     width: scrollViewWidth,
                                     height: scrollViewHeight)
            imagesScrollView.addSubview(imageView)
        }
        
        pageControl.numberOfItems = images.count
        pageControl.selectedItem = 0
    }
}

extension NftDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == currenciesCollectionView {
            return viewModel.detailsModel?.currencies.count ?? 0
        } else if collectionView == otherNftsCollectionView {
            return viewModel.cellModels.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == currenciesCollectionView {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NftDetailsCurrencyCollectionCell.defaultReuseIdentifier,
                    for: indexPath
                ) as? NftDetailsCurrencyCollectionCell,
                let cellModel = viewModel.detailsModel?.currencies[indexPath.item]
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: cellModel)
            return cell
            
        } else if collectionView == otherNftsCollectionView {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NftCollectionViewCell.defaultReuseIdentifier,
                    for: indexPath
                ) as? NftCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            let nft = viewModel.cellModels[indexPath.item]
            cell.configure(
                with: .collection,
                onLike: {
                    self.viewModel.toggleLikeNft(byId: nft.id)
                },
                onCart: {
                    self.viewModel.toggleCartNft(byId: nft.id)
                }
            )

            cell.setImage(nft.coverUrl)

            cell.setRating(nft.rating)
            cell.setPrice("\(nft.price) ETH")
            cell.setText(nft.name)

            let nftStates = viewModel.cellAdditionalModels
            cell.setLike(nftStates[nft.id]?.isLiked ?? false)
            cell.setInCart(nftStates[nft.id]?.isInCart ?? false)
            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == currenciesCollectionView {
            return CGSize(width: collectionView.bounds.width, height: 72)
        } else {
            return CGSize(width: 108, height: 192)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == currenciesCollectionView {
            return .zero
        } else {
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == otherNftsCollectionView {
            let cellModel = viewModel.cellModels[indexPath.row]

            let input = NftDetailsInput(nftId: cellModel.id, collectionId: cellModel.collectionId)
            let nftDetailsViewController = detailsAssembly.build(with: input)
            nftDetailsViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(nftDetailsViewController, animated: true)
        }
    }
}
