import UIKit

struct MockUser {
    let rank: String
    let avatar: UIImage
    let name: String
    let nfts: Int
}

final class StatisticsViewModel {
    private let nftService: NftService
    private(set) var users: [MockUser] = []
    
    var onDataUpdated: (() -> Void)?
    
    init(nftService: NftService) {
        self.nftService = nftService
    }
    
    func loadUsers() {
        let mockUsers = [
            MockUser(rank: "1", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 10),
            MockUser(rank: "2", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 9),
            MockUser(rank: "3", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 8),
            MockUser(rank: "4", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 7),
            MockUser(rank: "5", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 6),
            MockUser(rank: "6", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 5),
            MockUser(rank: "7", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 4),
            MockUser(rank: "8", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 3),
            MockUser(rank: "9", avatar: UIImage(named: "AvatarStub")!, name: "Alice", nfts: 2)
        ]
        
        self.users = mockUsers
        onDataUpdated?()
    }
}
