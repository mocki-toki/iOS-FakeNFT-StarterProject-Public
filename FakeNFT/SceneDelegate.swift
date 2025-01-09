import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if isFirstLaunch {
            let onboardingViewController = OnboardingPageViewController()
            let navigationController = UINavigationController(rootViewController: onboardingViewController)
            onboardingViewController.onboardingCompleted = {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                self.switchToTabBarController()
            }
            window.rootViewController = navigationController
        } else {
            switchToTabBarController()
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController(servicesAssembly: servicesAssembly)
        tabBarController.servicesAssembly = servicesAssembly
        window?.rootViewController = tabBarController
    }
}
