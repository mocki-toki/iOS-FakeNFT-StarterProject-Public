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
        
        userService.fetchUserDetails(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                
                switch result {
                case .success(let userDetails):
                    self?.user = userDetails
                case .failure(let error):
                    if let networkError = error as? NetworkClientError,
                       case .parsingError = networkError {
                        print("Parsing error: \(error.localizedDescription)")
                    } else {
                        print("Error loading user details: \(error.localizedDescription)")
                    }
                    self?.onErrorOccurred?("Failed to load user details. Please try again.", {
                        self?.loadUserDetails()
                    })
                }
            }
        }
    }
}
