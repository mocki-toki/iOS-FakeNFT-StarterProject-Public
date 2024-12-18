import UIKit

final class TabBarController: UITabBarController {
    var servicesAssembly: ServicesAssembly!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        viewControllers = TabBarFactory.createControllers(servicesAssembly: servicesAssembly)
        view.backgroundColor = .yWhite
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBar.appearance()
        appearance.tintColor = .yBlueUniversal
        appearance.unselectedItemTintColor = .yBlack
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.medium10,
            .foregroundColor: UIColor.yBlack
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.medium10,
            .foregroundColor: UIColor.yBlueUniversal
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
