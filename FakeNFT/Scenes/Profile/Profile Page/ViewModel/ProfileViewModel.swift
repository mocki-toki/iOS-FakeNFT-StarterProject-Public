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
        onLoadingStatusChanged?(true)
        
        profileNetworkService.fetchProfile { [weak self] result in
            self?.onLoadingStatusChanged?(false)
            switch result {
            case .success(let profile):
                self?.userProfile = profile
                Logger.log("Profile loaded: \(profile)")
            case .failure(let error):
                Logger.log("Error loading profile: \(error)", level: .error)
            }
        }
    }
    func updateMyNftCount(_ count: [String]) {
        if let profile = userProfile {
            userProfile = profile.updateMyNftCount(count)
        }
    }
    
    func updateFavoriteNftCount(_ count: [String]) {
        if let profile = userProfile {
            userProfile = profile.updateFavoriteNftCount(count)
        }
    }
    
    // MARK: - Private Methods
    private func updateProfileData() {
        onProfileDataUpdated?()
    }
    
    private func generateTableItems() -> [ProfileTableItem] {
        return [
            ProfileTableItem(title: "Мои NFT",
                             count: userProfile?.likes.count ?? 0,
                             destination: MyNftViewController()),
            ProfileTableItem(title: "Избранные NFT",
                             count: userProfile?.nfts.count ?? 0,
                             destination: FavoritesViewController()),
            ProfileTableItem(title: "О разработчике",
                             count: nil,
                             destination: WebViewController(viewModel: WebViewModel(urlString: "practicum.yandex.ru")))
        ]
    }
}
