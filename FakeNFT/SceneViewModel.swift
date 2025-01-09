import Foundation

final class SceneViewModel {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var isFirstLaunch: Bool {
        !userDefaults.bool(forKey: "hasSeenOnboarding")
    }
    
    func setHasSeenOnboarding() {
        userDefaults.set(true, forKey: "hasSeenOnboarding")
    }
}
