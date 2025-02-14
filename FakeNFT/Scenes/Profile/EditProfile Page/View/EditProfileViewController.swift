import UIKit
import Then
import SnapKit
import Kingfisher

final class EditProfileViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: EditProfileViewModelProtocol
    
    // MARK: - UI components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = .yBlack
        $0.hidesWhenStopped = true
    }
    
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .yBlack
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    private lazy var changePhotoButton = UIButton(type: .system).then {
        $0.setTitle(String(localizable: .editChangePhoto), for: .normal) // Сменить фото
        $0.titleLabel?.font = UIFont.medium10
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.tintColor = UIColor.textOnPrimary
        $0.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.text = String(localizable: .editName) // "Имя"
        $0.font = UIFont.bold22
    }
    
    private lazy var nameTextField = UITextField().then {
        $0.placeholder = String(localizable: .editNameTF) // "Введите имя"
        $0.backgroundColor = .yLightGrey
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.clearButtonMode = .whileEditing
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 16, height: 1)
        $0.leftView = paddingView
        $0.leftViewMode = .always
        
        $0.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.text = String(localizable: .editDescription) // "Описание"
        $0.font = UIFont.bold22
    }
    
    private lazy var descriptionTextView = UITextView().then {
        $0.backgroundColor = .yLightGrey
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        $0.delegate = self
    }
    
    private lazy var websiteLabel = UILabel().then {
        $0.text = String(localizable: .editWebsite) // "Сайт"
        $0.font = UIFont.bold22
    }
    
    private lazy var websiteTextField = UITextField().then {
        $0.placeholder = String(localizable: .editWebsiteTF) // "Введите ссылку на сайт"
        $0.backgroundColor = .yLightGrey
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.clearButtonMode = .whileEditing
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 16, height: 1)
        $0.leftView = paddingView
        $0.leftViewMode = .always
        $0.addTarget(self, action: #selector(websiteTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private lazy var formStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .leading
    }
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    // MARK: - Initializers
    init(viewModel: EditProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yWhite
        setupNavBar()
        setupViews()
        setupConstraints()
        setupKeyboardNotifications()
        setupInitialValues()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Navigation
    
    private func setupNavBar() {
        let closeButton = UIBarButtonItem(
            image: UIImage(named: "Close"),
            style: .plain,
            target: self,
            action: #selector(exitButtonDidTap)
        )
        closeButton.tintColor = UIColor.closeButton
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(changePhotoButton)
        
        [nameLabel, nameTextField, descriptionLabel,
        descriptionTextView, websiteLabel, websiteTextField]
        .forEach { formStackView.addArrangedSubview($0) }
        
        contentView.addSubview(formStackView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(scrollView)
            make.width.equalTo(view)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(contentView)
            make.width.height.equalTo(70)
        }
        
        changePhotoButton.snp.makeConstraints { make in
            make.centerX.equalTo(avatarImageView.snp.centerX)
            make.centerY.equalTo(avatarImageView.snp.centerY)
            make.width.equalTo(45)
            make.height.greaterThanOrEqualTo(24)
        }
        
        formStackView.snp.makeConstraints { make in
            make.top.equalTo(changePhotoButton.snp.bottom).offset(30)
            make.left.right.equalTo(contentView).inset(16)
            make.bottom.equalTo(contentView).offset(-30)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(formStackView.snp.width)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(132)
            make.width.equalTo(formStackView.snp.width)
        }
        
        websiteTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(formStackView.snp.width)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialValues() {
        let profile = viewModel.userProfile
        nameTextField.text = profile.name
        descriptionTextView.text = profile.description
        websiteTextField.text = profile.website
        
        if let avatarURL = URL(string: profile.avatar) {
            avatarImageView.kf.setImage(with: avatarURL)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func showAlertWithTextField(with currentURL: String, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(
            title: String(localizable: .editAlertName), // "Введите URL"
            message: String(localizable: .editAlertMessage), // "Пожалуйста, введите новый URL фотографии"
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = String(localizable: .editAlertName) // "Введите URL"
            textField.keyboardType = .URL
            textField.text = currentURL
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let okButton = UIAlertAction(title: String(localizable: .errorOk), style: .default) { _ in // "Ok"
            if let textField = alertController.textFields?.first,
               let newValue = textField.text {
                Logger.log("Новое значение URL: \(newValue)")
                completion(newValue)
            }
        }
        
        let cancelButton = UIAlertAction(title: String(localizable: .errorCancel), style: .cancel, handler: nil) // "Отмена"
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func disableUI() {
        [avatarImageView, changePhotoButton, nameTextField,
         descriptionTextView, websiteTextField].forEach { $0.isUserInteractionEnabled = false }
    }

    private func enableUI() {
        [avatarImageView, changePhotoButton, nameTextField,
         descriptionTextView, websiteTextField].forEach { $0.isUserInteractionEnabled = true }
    }
    
    private func showErrorAlert(message: String) {
        let buttons = [
            AlertPresenter.Button(
                title: String(localizable: .errorOk), action: nil, style: .default, isPreferred: true) // "Ok"
        ]
        AlertPresenter.presentAlert(
            on: self,
            title: String(localizable: .errorTitle), // "Ошибка"
            message: message,
            buttons: buttons
        )
    }
    
    // MARK: - Actions
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func changePhotoTapped() {
        let currentURL = viewModel.userProfile.avatar
        showAlertWithTextField(
            with: currentURL,
            completion: { [weak self] newURL in
                guard let self = self else { return }
                
                self.viewModel.updateAvatar(newURL)
                
                if let url = URL(string: newURL) {
                    self.avatarImageView.kf.setImage(with: url, options: [.cacheOriginalImage]) { result in
                        switch result {
                        case .success(let value):
                            Logger.log("Аватар успешно обновлен: \(value.source.url?.absoluteString ?? "")", level: .debug)
                        case .failure(let error):
                            Logger.log("Ошибка при обновлении аватара: \(error.localizedDescription)", level: .error)
                        }
                    }
                }
            }
        )
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        viewModel.updateUserName(textField.text ?? "")
    }
    
    @objc private func websiteTextFieldDidChange(_ textField: UITextField) {
        viewModel.updateUserWebsite(textField.text ?? "")
    }
    
    @objc private func bioTextViewDidChange(_ textView: UITextView) {
        viewModel.updateUserDescription(textView.text)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func exitButtonDidTap() {
        disableUI()
        
        viewModel.updateUserName(nameTextField.text ?? "")
        viewModel.updateUserDescription(descriptionTextView.text)
        viewModel.updateUserWebsite(websiteTextField.text ?? "")
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        viewModel.saveProfileData { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.enableUI()
                Logger.log("enableUI", level: .debug)
                
                switch result {
                case .success(let updatedProfile):
                    self?.viewModel.onProfileUpdated?(updatedProfile)
                    Logger.log("Профиль успешно обновлен: \(updatedProfile)")
                case .failure(let error):
                    Logger.log("Ошибка при обновлении профиля: \(error)", level: .error)
                    self?.showErrorAlert(message: "Не удалось обновить профиль. Пожалуйста, попробуйте позже.")
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioTextViewDidChange(textView)
        viewModel.updateUserDescription(textView.text)
    }
}
