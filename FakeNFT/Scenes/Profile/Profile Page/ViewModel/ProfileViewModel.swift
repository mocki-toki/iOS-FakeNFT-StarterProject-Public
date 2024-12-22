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
    func saveProfileData(completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileViewModel: ProfileViewViewModelType {
    // MARK: - Public Properties
    var userProfile: Profile? {
        didSet {
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
                print("Profile loaded: \(profile)")
            case .failure(let error):
                print("Error loading profile: \(error)")
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
    
    func saveProfileData(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let profile = userProfile else { return }
        
        var encodedLikes = profile.likes.map { String($0) }.joined(separator: ",")
        if encodedLikes.isEmpty {
            encodedLikes = "null"
        }
        
        let profileData = "name=\(profile.name)&description=\(profile.description)&website=\(profile.website)&avatar=\(profile.avatar)&likes=\(encodedLikes)"
        
        profileNetworkService.updateProfile(profileData: profileData) { result in
            switch result {
            case .success(let updatedProfile):
                self.userProfile = updatedProfile
                completion(.success(updatedProfile))
            case .failure(let error):
                completion(.failure(error))
            }
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
