import UIKit

final class CatalogViewController: UIViewController {
    let servicesAssembly: ServicesAssembly
    let testNftButton = UIButton()

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yWhite

        view.addSubview(testNftButton)
        testNftButton.constraintCenters(to: view)
        testNftButton.setTitle(Constants.openNftTitle, for: .normal)
        testNftButton.setTitleColor(.systemBlue, for: .normal)
    }
}

private enum Constants {
    static let openNftTitle = String(localizable: .catalogOpenNft)
    static let testNftId = "7773e33c-ec15-4230-a102-92426a3a6d5a"
}
