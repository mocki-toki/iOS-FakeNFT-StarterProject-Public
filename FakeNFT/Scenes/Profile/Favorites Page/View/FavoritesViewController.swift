import UIKit

final class FavoritesViewController: UIViewController {
    // MARK: - Properties
    
//    private var viewModel: FavoritesViewModelProtocol
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yWhite
        
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
        view.addSubview(stubLabel)
    }
    
    private func setupConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
//        tableView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
//            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
        
        stubLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backwardButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}
