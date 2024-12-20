import UIKit

final class TabBarController: UITabBarController {
    var servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
