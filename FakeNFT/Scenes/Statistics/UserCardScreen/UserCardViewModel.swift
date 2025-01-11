import Foundation
import ProgressHUD

final class UserCardViewModel {
    private let userId: String
    private let userService: UserService
    let website: String
    
    var user: Users? {
        didSet {
            onDataUpdated?()
        }
    }
    var onDataUpdated: (() -> Void)?
    var onErrorOccurred: ((String, @escaping () -> Void) -> Void)?
    
    init(userId: String, userService: UserService, website: String) {
        self.userId = userId
        self.userService = userService
        self.website = website

        loadUserDetails()
    }
    
    func loadUserDetails() {
        ProgressHUD.show()
        Logger.log("Started loading user details for userId: \(userId)", level: .info)

        userService.fetchUserDetails(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()

                switch result {
                case .success(let userDetails):
                    Logger.log("Successfully loaded user details: \(userDetails.name)", level: .info)
                    self?.user = userDetails
                case .failure(let error):
                    if let networkError = error as? NetworkClientError, case .parsingError = networkError {
                        Logger.log("Parsing error: \(error.localizedDescription)", level: .warning)
                    } else {
                        Logger.log("Error loading user details: \(error.localizedDescription)", level: .error)
                    }
                    self?.onErrorOccurred?("Failed to load user details. Please try again.", {
                        self?.loadUserDetails()
                    })
                }
            }
        }
    }
}
