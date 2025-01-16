import UIKit

final class SecondaryButton: UIButton {
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
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.setTitleColor(.yBlack, for: .normal)
        self.setTitleColor(.yGreyUniversal, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.layer.cornerRadius = 16
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.yBlack.cgColor
    }
}
