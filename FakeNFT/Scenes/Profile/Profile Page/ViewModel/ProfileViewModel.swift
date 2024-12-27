import UIKit

protocol ProfileViewViewModelType {
    // MARK: - Public Properties
    var tableItems: [ProfileTableItem] { get }
    var userProfile: Profile? { get set }
    var onProfileDataUpdated: (() -> Void)? { get set }
    var onLoadingStatusChanged: ((Bool) -> Void)? { get set }
    
    // MARK: - Initializers
    init(profileNetworkService: ProfileNetworkServiceProtocol)
    
    // MARK: - Public Methods
    func loadData()
    func updateMyNftCount(_ count: [String])
    func updateFavoriteNftCount(_ count: [String])
}

final class ProfileViewModel: ProfileViewViewModelType {
    // MARK: - Public Properties
    var userProfile: Profile? {
        didSet {
            guard oldValue != userProfile else { return }
            Logger.log("Profile was updated")
            updateProfileData()
        }
    }
    
    var onProfileDataUpdated: (() -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    private let profileNetworkService: ProfileNetworkServiceProtocol
    private(set) var tableItems: [ProfileTableItem] = []
    
    // MARK: - Initializers
    init(profileNetworkService: ProfileNetworkServiceProtocol) {
        self.profileNetworkService = profileNetworkService
        self.tableItems = generateTableItems()
    }
    
    // MARK: - Public Methods
    func loadData() {
        DispatchQueue.main.async {
            self.onLoadingStatusChanged?(true)
        }
        
        profileNetworkService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStatusChanged?(false)
                
                switch result {
                case .success(let profile):
                    self?.userProfile = profile
                    Logger.log("Profile loaded: \(profile)")
                    Logger.log("Favorites NFT: \(profile.likes.count)")
                    Logger.log("NFT: \(profile.nfts.count)")
                case .failure(let error):
                    Logger.log("Error loading profile: \(error)", level: .error)
                }
            }
        }
    }
    
    func updateMyNftCount(_ count: [String]) {
        userProfile = userProfile.map { $0.updateMyNftCount(count) }
    }

    func updateFavoriteNftCount(_ count: [String]) {
        userProfile = userProfile.map { $0.updateFavoriteNftCount(count) }
    }
    
    // MARK: - Private Methods
    private func updateProfileData() {
        DispatchQueue.main.async {
            self.tableItems = self.generateTableItems()
            self.onProfileDataUpdated?()
        }
    }
    
    private func generateTableItems() -> [ProfileTableItem] {
        return [
            ProfileTableItem(title: String(localizable: .profileLinksMyNfts),
                             count: userProfile?.nfts.count ?? 0,
                             destination: MyNftViewController(viewModel: MyNFTViewModel())),
            ProfileTableItem(title: String(localizable: .profileLinksFavorites),
                             count: userProfile?.likes.count ?? 0,
                             destination: FavoritesViewController()),
            ProfileTableItem(title: String(localizable: .profileLinksDeveloper),
                             count: nil,
                             destination: WebViewController(viewModel: WebViewModel(urlString: "practicum.yandex.ru")))
        ]
    }
}
