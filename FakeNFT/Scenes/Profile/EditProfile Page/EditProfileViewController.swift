import UIKit
import Then
import SnapKit

class EditProfileViewController: UIViewController {
    // MARK: - Properties
    let currentURL = "test"
    // MARK: - UI components
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    private lazy var changePhotoButton = UIButton(type: .system).then {
        $0.setTitle("Сменить фото", for: .normal)
        $0.titleLabel?.font = UIFont.medium10
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.tintColor = UIColor.textOnPrimary
        $0.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.text = "Имя"
        $0.font = UIFont.bold22
    }
    
    private lazy var nameTextField = UITextField().then {
        $0.placeholder = "Введите имя"
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
    }
    
    private lazy var bioLabel = UILabel().then {
        $0.text = "Описание"
        $0.font = UIFont.bold22
    }
    
    private lazy var bioTextView = UITextView().then {
        $0.backgroundColor = .yLightGrey
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
    }
    
    private lazy var websiteLabel = UILabel().then {
        $0.text = "Сайт"
        $0.font = UIFont.bold22
    }
    
    private lazy var websiteTextField = UITextField().then {
        $0.placeholder = "Введите ссылку на сайт"
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
    }
    
    private lazy var formStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .leading
    }
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yWhite
        setupNavBar()
        setupViews()
        setupConstraints()
        setupKeyboardNotifications()
        
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
        
        formStackView.addArrangedSubview(nameLabel)
        formStackView.addArrangedSubview(nameTextField)
        formStackView.addArrangedSubview(bioLabel)
        formStackView.addArrangedSubview(bioTextView)
        formStackView.addArrangedSubview(websiteLabel)
        formStackView.addArrangedSubview(websiteTextField)
        
        contentView.addSubview(formStackView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(view)
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
        
        bioTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(132)
            make.width.equalTo(formStackView.snp.width)
        }
        
        websiteTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(formStackView.snp.width)
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
    
    func showAlertWithTextField() {
        let okButton = AlertPresenter.Button(
            title: "OK",
            action: {
                if let text = self.getTextFieldValue() {
                    print("Введенный URL: \(text)")
                }
            },
            style: .default,
            isPreferred: true
        )
        
        let cancelButton = AlertPresenter.Button(
            title: "Отмена",
            action: nil,
            style: .cancel,
            isPreferred: false
        )
        
        AlertPresenter.presentAlert(
            on: self,
            title: "Введите URL",
            message: "Пожалуйста, введите новый URL фотографии",
            buttons: [okButton, cancelButton],
            textFieldHandler: { textField in
                textField.placeholder = "Введите URL"
                textField.keyboardType = .URL
                textField.text = self.currentURL
                textField.clearButtonMode = .whileEditing
                textField.autocapitalizationType = .none
                textField.autocorrectionType = .no
            }
        )
    }
    
    func getTextFieldValue() -> String? {
        guard let alertController = self.presentedViewController as? UIAlertController,
              let textField = alertController.textFields?.first else {
            return nil
        }
        return textField.text
    }
    
    // MARK: - Actions
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func changePhotoTapped() {
        // Логика для смены фото
        print("Change photo button tapped")
        showAlertWithTextField()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func exitButtonDidTap() {
        print("NavBarItem tapped!")
        dismiss(animated: true, completion: nil)
    }
}
