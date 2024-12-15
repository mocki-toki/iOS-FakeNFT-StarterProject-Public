import UIKit

final class TabBarFactory {
    static func createControllers(servicesAssembly: ServicesAssembly) -> [UIViewController] {
        return [
            ProfileViewController(servicesAssembly: servicesAssembly)
                .configured(with: "Tab.profile", image: UIImage.inactiveProfile, tag: 0),
            
            CatalogViewController(servicesAssembly: servicesAssembly)
                .configured(with: "Tab.catalog", image: UIImage.inactiveCatalog, tag: 1),
            
            CartViewController(servicesAssembly: servicesAssembly)
                .configured(with: "Tab.cart", image: UIImage.inactiveCart, tag: 2),
            
            StatisticsViewController(servicesAssembly: servicesAssembly)
                .configured(with: "Tab.statistics", image: UIImage.inactiveStatistics, tag: 3)
        ]
    }
}

extension UIViewController {
    func configured(with titleKey: String, image: UIImage, tag: Int) -> UIViewController {
        self.tabBarItem = UITabBarItem(
            title: NSLocalizedString(titleKey, comment: ""),
            image: image,
            tag: tag
        )
        return self
    }
}
