import UIKit

final class StatisticsViewModel {
    private let nftService: NftService
    private let userService: UserService
    
    enum Sort: String {
        case byRate
        case byName
    }
    
    var users: [Users] = [] {
        didSet {
            onDataUpdated?()
        }
    }
    var onDataUpdated: (() -> Void)?
    
    init(nftService: NftService, userService: UserService) {
        self.nftService = nftService
        self.userService = userService
    }
    
    func loadUsers() {
        userService.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUsers):
                    self?.users = fetchedUsers.sorted { $0.nfts.count > $1.nfts.count }
                case .failure(let error):
                    print("Error fetching users: \(error)")
                }
            }
        }
    }
    
    func sortedUsers(_ type: Sort) {
        switch type {
        case .byRate:
            users = users.sorted { $0.nfts.count > $1.nfts.count }
        case .byName:
            users = users.sorted { $0.name < $1.name }
        }
    }
}
