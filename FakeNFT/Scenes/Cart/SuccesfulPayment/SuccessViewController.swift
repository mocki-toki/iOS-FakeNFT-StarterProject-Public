import UIKit
import SnapKit
import Then

final class SuccessViewController: UIViewController {
    var onDismiss: (() -> Void)?
    
    // MARK: - Private Properties
    private let viewModel = SuccessViewModel()
    
    private lazy var successImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: viewModel.successData.imageName)
    }
    
    private lazy var successLabel = UILabel().then {
        $0.text = viewModel.successData.message
        $0.font = .bold22
        $0.textColor = .yBlack
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var successButton = PrimaryButton(title: viewModel.successData.buttonText).then {
        $0.addTarget(self, action: #selector(successButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(successImageView)
        view.addSubview(successLabel)
        view.addSubview(successButton)
        
        successImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(196)
            make.width.height.equalTo(278)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        successButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
        }
    }
    
    @objc private func successButtonTapped() {
        onDismiss?()
        guard let tabBarController = presentingViewController as? UITabBarController else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        tabBarController.selectedIndex = 1
        dismiss(animated: true, completion: nil)
    }
}
