import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    private let viewModel = SceneViewModel()
    private let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            
            if viewModel.isFirstLaunch {
                Logger.log("App launched for the first time, showing onboarding")
                showOnboarding()
            } else {
                Logger.log("App launched, showing TabBar")
                showTabBar()
            }
            
            window?.makeKeyAndVisible()
        }
    
    // MARK: - Private Methods
    
    private func showOnboarding() {
        let onboardingViewController = OnboardingPageViewController()
        let navigationController = UINavigationController(rootViewController: onboardingViewController)
        onboardingViewController.onboardingCompleted = { [weak self] in
            self?.viewModel.setHasSeenOnboarding()
            self?.showTabBar()
        }
        window?.rootViewController = navigationController
    }
    
    private func showTabBar() {
        let tabBarController = TabBarController(servicesAssembly: servicesAssembly)
        window?.rootViewController = tabBarController
    }
}
