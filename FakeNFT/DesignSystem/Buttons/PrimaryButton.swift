import UIKit

final class PrimaryButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setupButton()
        self.setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.backgroundColor = .yBlack
        self.setTitleColor(.yWhite, for: .normal)
        self.setTitleColor(.yGreyUniversal, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.layer.cornerRadius = 16
    }
}

