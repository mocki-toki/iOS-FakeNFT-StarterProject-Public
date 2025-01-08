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
        
        nftService.loadUserDetails(userId: userId) { [weak self] (result: Result<Users, Error>) in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                switch result {
                case .success(let user):
                    let nftIds = user.nfts
                    self?.loadNftsByIds(nftIds)
                case .failure(let error):
                    self?.onErrorOccurred?("Error loading user details: \(error.localizedDescription)", {
                        self?.loadUserNfts()
                    })
                }
            }
        }
    }
    
    func loadNftsByIds(_ nftIds: [String]) {
        let group = DispatchGroup()
        var loadedNfts: [Nft] = []
        var errors: [Error] = []
        
        nftIds.forEach { nftId in
            group.enter()
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nft):
                    loadedNfts.append(nft)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                self.nfts = loadedNfts
                self.onDataUpdated?()
            } else {
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
