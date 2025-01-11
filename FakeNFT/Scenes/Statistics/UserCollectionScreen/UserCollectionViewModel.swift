import Foundation
import ProgressHUD

final class UserCollectionViewModel {
    private let nftService: NftService
    private var userId: String
    private var nfts: [Nft] = []
    
    var onDataUpdated: (() -> Void)?
    var onErrorOccurred: ((String, @escaping () -> Void) -> Void)?
    
    init(userId: String, nftService: NftService) {
        self.userId = userId
        self.nftService = nftService
    }
    
    func loadUserNfts() {
        ProgressHUD.show()
        Logger.log("Started loading NFTs for userId: \(userId)", level: .info)
        
        nftService.loadUserDetails(userId: userId) { [weak self] (result: Result<Users, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    Logger.log("Successfully loaded user details with \(user.nfts.count) NFTs", level: .info)
                    let nftIds = user.nfts.map { $0.uuidString }
                    self?.loadNftsByIds(nftIds)
                case .failure(let error):
                    ProgressHUD.dismiss()
                    Logger.log("Error loading user details: \(error.localizedDescription)", level: .error)
                    self?.onErrorOccurred?("Error loading user details: \(error.localizedDescription)", {
                        self?.loadUserNfts()
                    })
                }
            }
        }
    }
    
    func loadNftsByIds(_ nftIds: [String]) {
        Logger.log("Started loading NFTs by IDs: \(nftIds)", level: .info)
        let group = DispatchGroup()
        var loadedNfts: [Nft] = []
        var errors: [Error] = []
        
        nftIds.forEach { nftId in
            guard let uuid = UUID(uuidString: nftId) else {
                Logger.log("Invalid UUID string: \(nftId)", level: .error)
                errors.append(NSError(domain: "Invalid UUID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID: \(nftId)"]))
                return
            }
            
            group.enter()
            nftService.loadNft(id: uuid) { result in
                switch result {
                case .success(let nft):
                    Logger.log("Successfully loaded NFT with id: \(nft.id)", level: .info)
                    loadedNfts.append(nft)
                case .failure(let error):
                    Logger.log("Error loading NFT with id \(nftId): \(error.localizedDescription)", level: .error)
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            ProgressHUD.dismiss()
            if errors.isEmpty {
                Logger.log("Successfully loaded all NFTs", level: .info)
                self.nfts = loadedNfts
                self.onDataUpdated?()
            } else {
                Logger.log("Failed to load some NFTs", level: .warning)
                self.onErrorOccurred?("Failed to load some NFTs.", {
                    self.loadNftsByIds(nftIds)
                })
            }
        }
    }
    
    
    func getNfts() -> [Nft] {
        return nfts
    }
}
