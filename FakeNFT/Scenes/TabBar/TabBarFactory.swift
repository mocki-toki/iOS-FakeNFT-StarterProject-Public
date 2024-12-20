import UIKit

final class TabBarFactory {
    static func createControllers(servicesAssembly: ServicesAssembly) -> [UIViewController] {
        return [
            UINavigationController(rootViewController: ProfileViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabProfile), image: UIImage.inactiveProfile, tag: 0),
            
            UINavigationController(rootViewController: CatalogViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabCatalog), image: UIImage.inactiveCatalog, tag: 1),
            
            UINavigationController(
                rootViewController: CartViewController(
                    servicesAssembly: servicesAssembly,
                    viewModel: createCartViewModel()
                )
            ).configured(with: String(localizable: .tabCart), image: UIImage.inactiveCart, tag: 2),
            
            UINavigationController(rootViewController: StatisticsViewController(servicesAssembly: servicesAssembly))
                .configured(with: String(localizable: .tabStatistics), image: UIImage.inactiveStatistics, tag: 3)
        ]
    }
    
    // MARK: - Test Data Factory
    
    private static func createCartViewModel() -> CartViewModel {
        let image = UIImage(named: "SucessfulPayment")
        let testItems = [
            CartItem(name: "April", price: 1.78, rating: 1, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "Greena", price: 2.5, rating: 4, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "April", price: 1.78, rating: 1, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "Greena", price: 2.5, rating: 4, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "April", price: 1.78, rating: 1, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "Greena", price: 2.5, rating: 4, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "April", price: 1.78, rating: 1, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "Greena", price: 2.5, rating: 4, image: image ?? UIImage(), isInCart: true),
            CartItem(name: "Spring", price: 3.0, rating: 5, image: image ?? UIImage(), isInCart: true)
        ]
        return CartViewModel(items: testItems)
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
