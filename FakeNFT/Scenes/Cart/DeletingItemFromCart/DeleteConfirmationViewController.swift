import SnapKit
import Then
import UIKit

final class DeleteConfirmationViewController: UIViewController {
    // MARK: - Private Properties
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let nftImageView = UIImageView()
    private let messageLabel = UILabel()
    private let confirmButton = UIButton()
    private let cancelButton = UIButton()
    private let containerView = UIView()
    private let buttonStackView = UIStackView()
    private let viewModel: DeleteConfirmationViewModel

    // MARK: - Initializer
    init(viewModel: DeleteConfirmationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }

    // MARK: - Private Methods
    private func setupView() {
        setupBackground()
        setupContainer()
        setupButtons()
        setupConstraints()
    }

    private func setupBackground() {
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.05)

        blurEffectView.do {
            $0.alpha = 1.0
        }

        view.addSubview(blurEffectView)
    }

    private func setupContainer() {
        nftImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.backgroundColor = .gray
        }

        messageLabel.do {
            $0.text = viewModel.message
            $0.textColor = .yBlack
            $0.font = .regular13
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        containerView.addSubview(nftImageView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonStackView)
        view.addSubview(containerView)
    }

    private func setupButtons() {
        confirmButton.do {
            $0.setTitle(viewModel.confirmButtonText, for: .normal)
            $0.setTitleColor(.yRedUniversal, for: .normal)
            $0.backgroundColor = .yBlack
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = .regular17
            $0.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        }

        cancelButton.do {
            $0.setTitle(viewModel.cancelButtonText, for: .normal)
            $0.backgroundColor = .yBlack
            $0.titleLabel?.font = .regular17
            $0.setTitleColor(.yWhite, for: .normal)
            $0.layer.cornerRadius = 12
            $0.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        }

        buttonStackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 8
        }

        buttonStackView.addArrangedSubview(confirmButton)
        buttonStackView.addArrangedSubview(cancelButton)
    }

    private func setupConstraints() {
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.width.equalTo(262)
            make.height.equalTo(220)
            make.center.equalToSuperview()
        }

        nftImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(125)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nftImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }
    }

    private func setupBindings() {
        nftImageView.image = viewModel.nftImage
    }

    @objc private func handleConfirm() {
        viewModel.confirmDeletion()
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleCancel() {
        viewModel.cancelDeletion()
        dismiss(animated: true, completion: nil)
    }
}
