import UIKit
import Then
import SnapKit

class EditProfileViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - UI components
    private lazy var avatarImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    private lazy var changePhotoButton = UIButton(type: .system).then {
        $0.setTitle("Сменить фото", for: .normal)
        $0.titleLabel?.font = UIFont.medium10
        $0.titleLabel?.numberOfLines = 2 // Разрешаем несколько строк
        $0.titleLabel?.textAlignment = .center // Выравнивание текста по центру (если нужно)
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
        
        // Добавляем жест для скрытия клавиатуры при касании экрана
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
    }
    
    @objc private func dismissKeyboard() {
        // Закрываем клавиатуру при касании экрана
        view.endEditing(true)
    }
    
    @objc private func exitButtonDidTap() {
        print("NavBarItem tapped!")
        dismiss(animated: true, completion: nil)
    }
}
