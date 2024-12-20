import UIKit

final class TabBarFactory {
    static func createControllers(servicesAssembly: ServicesAssembly) -> [UIViewController] {
        return [
            UINavigationController(rootViewController: ProfileViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabProfile), image: UIImage.inactiveProfile, tag: 0),
            
            UINavigationController(rootViewController: CatalogViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabCatalog), image: UIImage.inactiveCatalog, tag: 1),
            
            UINavigationController(rootViewController: CartViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabCart), image: UIImage.inactiveCart, tag: 2),
            
            UINavigationController(rootViewController: StatisticsViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabStatistics), image: UIImage.inactiveStatistics, tag: 3)
        ]
    }
}

extension UIViewController {
    func configured(with title: String, image: UIImage, tag: Int) -> UIViewController {
        self.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            tag: tag
        )
        return self
    }
}
