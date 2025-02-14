import Kingfisher
import SafariServices
import UIKit

protocol CollectionDetailsView: AnyObject, ErrorView, LoadingView {
    func displayCollectionDetails(_ collectionDetails: CollectionDetailsModel)
}

final class CollectionDetailsViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: CollectionDetailsViewModel
    private let detailsAssembly: NftDetailsAssembly

    private lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.backgroundColor = .yWhite
    }

    private lazy var contentView = UIView().then {
        $0.backgroundColor = .yWhite
    }

    private lazy var nftCollectionView: UICollectionView = {
        let layout = createCompositionalLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            NftCollectionViewCell.self, forCellWithReuseIdentifier: "NftCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    private lazy var coverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.layer.masksToBounds = true
    }

    private lazy var nameLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .bold22
    }

    private lazy var authorCaptionLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .regular13
        $0.text = String(localizable: .catalogDetailsAuthor)
    }

    private lazy var authorLabel = UILabel().then {
        $0.textColor = .primary
        $0.font = .regular15
        $0.isUserInteractionEnabled = true
    }

    private lazy var descriptionLabel = UILabel().then {
        $0.textColor = .textPrimary
        $0.font = .regular13
        $0.numberOfLines = 0
    }

    lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Lifecycle

    init(viewModel: CollectionDetailsViewModel, detailsAssembly: NftDetailsAssembly) {
        self.viewModel = viewModel
        self.detailsAssembly = detailsAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupBindings()
        setupNavigationBar()
        setupAuthorLabelTap()

        viewModel.fetchCollectionDetails()
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
            make.width.equalTo(view)
        }

        [
            activityIndicator, coverImageView, nameLabel, authorCaptionLabel, authorLabel,
            descriptionLabel, nftCollectionView
        ].forEach { item in
            contentView.addSubview(item)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(310)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        authorCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(13)
            make.leading.equalTo(nameLabel.snp.leading)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.leading.equalTo(authorCaptionLabel.snp.trailing).offset(4)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(authorCaptionLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
        }

        nftCollectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(calculateCollectionViewHeight())
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func calculateCollectionViewHeight() -> CGFloat {
        let itemsPerRow = 3
        let itemHeight: CGFloat = 192
        let spacing: CGFloat = 16
        let numberOfItems = viewModel.cellModels.count
        let rows = ceil(CGFloat(numberOfItems) / CGFloat(itemsPerRow))
        return rows * itemHeight + (rows - 1) * spacing
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(192)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(192)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(9)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 0, trailing: 16)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func setupBindings() {
        setupCollectionDetailsBinding()
        setupNftsBinding()
        setupNftAdditionalsBinding()
    }

    private func setupCollectionDetailsBinding() {
        viewModel.stateDidChanged = { [weak self] state in
            self?.hideLoading()
            switch state {
            case .data(let collectionDetailsModel):
                self?.displayCollectionDetails(collectionDetailsModel)
            case .failed(let error):
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchCollectionDetails() }
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
                self?.showNftsLoading()
            case .data:
                self?.hideNftsLoading()
                self?.updateCollectionViewHeight()
                DispatchQueue.main.async {
                    self?.nftCollectionView.reloadData()
                    self?.setupLayout()
                }
            case .failed(let error):
                self?.hideNftsLoading()
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchCollectionDetails() }
                )
                self?.showError(errorModel)
            }
        }
    }

    private func setupNftAdditionalsBinding() {
        viewModel.stateOfNftAdditionalsDidChanged = { [weak self] state in
            switch state {
            case .initial, .loading:
                self?.showNftsLoading()
                self?.nftCollectionView.alpha = 0.5
            case .data:
                self?.hideNftsLoading()
                self?.updateCollectionViewHeight()
                self?.nftCollectionView.alpha = 1
                DispatchQueue.main.async {
                    self?.nftCollectionView.reloadData()
                }
            case .failed(let error):
                self?.hideNftsLoading()
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchCollectionDetails() }
                )
                self?.showError(errorModel)
                self?.nftCollectionView.alpha = 1
            }
        }
    }

    private func updateCollectionViewHeight() {
        nftCollectionView.snp.updateConstraints { make in
            make.height.equalTo(calculateCollectionViewHeight())
        }
    }

    private func setupNavigationBar() {
        let backImage = UIImage.backward.withTintColor(
            .yBlack, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Loading Indicators

    private func showNftsLoading() {
        activityIndicator.stopAnimating()
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.remakeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50)
        }
        activityIndicator.startAnimating()
    }

    private func hideNftsLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    private func setupAuthorLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(tapGesture)
    }

    @objc private func authorLabelTapped() {
        guard let url = viewModel.detailsModel?.authorSiteUrl else {
            print("Invalid URL")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}

// MARK: - CollectionDetailsView

extension CollectionDetailsViewController: CollectionDetailsView {
    func displayCollectionDetails(_ collectionDetails: CollectionDetailsModel) {
        coverImageView.kf.setImage(with: collectionDetails.coverUrl)
        nameLabel.text = collectionDetails.name
        authorLabel.text = collectionDetails.author
        descriptionLabel.text = collectionDetails.description

        setupLayout()
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int {
        return viewModel.cellModels.count
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

            if let url = URL(string: nft.coverUrl) {
                
            cell.setImage(url)
            }

        cell.setRating(nft.rating)
        cell.setPrice("\(nft.price) ETH")
        cell.setText(nft.name)

        let nftStates = viewModel.cellAdditionalModels
        cell.setLike(nftStates[nft.id]?.isLiked ?? false)
        cell.setInCart(nftStates[nft.id]?.isInCart ?? false)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = viewModel.cellModels[indexPath.row]

        let input = NftDetailsInput(nftId: cellModel.id, collectionId: cellModel.collectionId)
        let nftDetailsViewController = detailsAssembly.build(with: input)
        nftDetailsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nftDetailsViewController, animated: true)
    }
}
