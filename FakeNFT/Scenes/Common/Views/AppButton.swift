import UIKit

enum AppButtonStyle {
    case primary
    case secondary
}

final class AppButton: UIButton {
    func setStyle(_ style: AppButtonStyle) {
        switch style {
            case .primary:
                self.backgroundColor = .yBlack
                self.setTitleColor(.yWhite, for: .normal)
                self.setTitleColor(.yGreyUniversal, for: .highlighted)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
                self.layer.cornerRadius = 16
            case .secondary:
                self.backgroundColor = .clear
                self.layer.borderWidth = 1
                self.setTitleColor(.yBlack, for: .normal)
                self.setTitleColor(.yGreyUniversal, for: .highlighted)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                self.layer.cornerRadius = 16
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.yBlack.cgColor
    }
}
