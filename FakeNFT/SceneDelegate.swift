import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let tabBarController = TabBarController(servicesAssembly: servicesAssembly)
        tabBarController.servicesAssembly = servicesAssembly
        
        let window = UIWindow(windowScene: windowScene)
        
        let onboardingViewController = OnboardingPageViewController()
        let navigationController = UINavigationController(rootViewController: onboardingViewController)
        
//        window.rootViewController = tabBarController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
