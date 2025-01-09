import UIKit
import SnapKit
import Then

final class OnboardingContentViewController: UIViewController {
    private let viewModel: OnboardingSlideViewModel
    
    // MARK: - UI Elements
    
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let gradientView = GradientView(
        colors: [
            UIColor.yBlackUniversal.withAlphaComponent(1.0),
            UIColor.yBlackUniversal.withAlphaComponent(0.0)
        ],
        startPoint: CGPoint(x: 0.5, y: 0.0),
        endPoint: CGPoint(x: 0.5, y: 1.0)
    )
    
    let titleLabel = UILabel().then {
        $0.font = .bold32
        $0.textColor = .yWhiteUniversal
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular15
        $0.textColor = .yWhiteUniversal
        $0.numberOfLines = 0
    }
    
    private let closeButton = UIButton().then {
        let image = UIImage(resource: .close).withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = .yWhiteUniversal
    }
    
    private lazy var actionButton: PrimaryButton = PrimaryButton(
        title: String(localizable: .onboardingSlide3Button)).then {
            $0.backgroundColor = .yBlackUniversal
            $0.setTitleColor(.yWhiteUniversal, for: .normal)
            $0.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
    
    // MARK: - Properties
    
    var closeButtonAction: (() -> Void)?
    var actionButtonAction: (() -> Void)?
    
    // MARK: - Initializer
    
    init(viewModel: OnboardingSlideViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(gradientView)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)
        view.addSubview(actionButton)
        
        setupConstraints()
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(42)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(186)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        actionButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(66)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
    }
    
    private func configureUI() {
        backgroundImageView.image = viewModel.image
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        closeButton.isHidden = viewModel.isLastSlide
        actionButton.isHidden = !viewModel.isLastSlide
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        closeButtonAction?()
    }
    
    @objc private func didTapActionButton() {
        closeButtonAction?()
    }
}
