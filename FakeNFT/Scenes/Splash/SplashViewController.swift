import UIKit
import SnapKit
import Then

final class SplashViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel = SplashViewModel()
    private let servicesAssembly: ServicesAssembly
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .logo.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .yBlack
    }
    
    // MARK: - Initializers
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yWhite
        setupUI()
        proceedAfterDelay()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Navigation
    
    private func proceedAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if !viewModel.isFirstLaunch {
                Logger.log("App launched, showing TabBar")
                self.showTabBar()
            } else {
                Logger.log("App launched for the first time, showing onboarding")
                self.showOnboarding()
            }
        }
    }
    
    private func showOnboarding() {
        let onboardingViewController = OnboardingPageViewController()
        let navigationController = UINavigationController(rootViewController: onboardingViewController)
        onboardingViewController.onboardingCompleted = {
            self.viewModel.setHasSeenOnboarding()
            self.showTabBar()
        }
        UIApplication.shared.windows.first?.rootViewController = navigationController
    }
    
    private func showTabBar() {
        let tabBarController = TabBarController(servicesAssembly: servicesAssembly)
        UIApplication.shared.windows.first?.rootViewController = tabBarController
    }
}
