import Foundation

final class SceneViewModel {
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let onboardingKey = "hasSeenOnboarding"
    
    // MARK: - Initializer
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Methods
    
    var isFirstLaunch: Bool {
        !userDefaults.bool(forKey: onboardingKey)
    }
    
    func setHasSeenOnboarding() {
        userDefaults.set(true, forKey: onboardingKey)
    }
}
