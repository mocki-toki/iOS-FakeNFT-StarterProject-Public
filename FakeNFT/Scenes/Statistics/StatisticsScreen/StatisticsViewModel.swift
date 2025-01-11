import UIKit
import ProgressHUD

final class StatisticsViewModel {
    private let nftService: NftService
    private let userService: UserService
    
    private let sortKey = "currentSortType"
    
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
    var onErrorOccurred: ((String, @escaping () -> Void) -> Void)?
    
    private(set) var currentSortType: Sort = .byRate {
        didSet {
            UserDefaults.standard.set(currentSortType.rawValue, forKey: sortKey)
        }
    }
    
    init(nftService: NftService, userService: UserService) {
        self.nftService = nftService
        self.userService = userService
        self.currentSortType = Sort(rawValue: UserDefaults.standard.string(forKey: sortKey) ?? "byRate") ?? .byRate
    }
    
    func loadUsers() {
        ProgressHUD.show()
        Logger.log("Started loading users", level: .info)

        userService.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                switch result {
                case .success(let fetchedUsers):
                    Logger.log("Successfully loaded users: \(fetchedUsers.count) users fetched", level: .info)
                    self?.users = self?.applySorting(to: fetchedUsers) ?? []
                case .failure(let error):
                    Logger.log("Error fetching users: \(error.localizedDescription)", level: .error)
                    self?.onErrorOccurred?(String(localizable: .alertErroMessage), {
                        self?.loadUsers()
                    })
                }
            }
        }
    }
    
    func sortedUsers(_ type: Sort) {
        currentSortType = type
        users = applySorting(to: users)
    }
    
    private func applySorting(to users: [Users]) -> [Users] {
        switch currentSortType {
        case .byRate:
            return users.sorted { $0.nfts.count > $1.nfts.count }
        case .byName:
            return users.sorted { $0.name < $1.name }
        }
    }
}
