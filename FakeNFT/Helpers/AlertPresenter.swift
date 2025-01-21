import UIKit

// MARK: - Alert Presenter
final class AlertPresenter {
    struct Button {
        let title: String
        let action: (() -> Void)?
        let style: UIAlertAction.Style
        let isPreferred: Bool
    }

    static func presentAlert(
        on viewController: UIViewController,
        title: String?, message: String?, buttons: [Button]
    ) {
        let alertController = UIAlertController(
            title: title, message: message, preferredStyle: .alert)

        var preferredUIAlertAction: UIAlertAction?
        if !buttons.isEmpty {
            for button in buttons {
                let action = UIAlertAction(title: button.title, style: button.style) { _ in
                    button.action?()
                }
                alertController.addAction(action)

                if button.isPreferred {
                    preferredUIAlertAction = action
                }
            }

            alertController.preferredAction = preferredUIAlertAction
        }

        viewController.present(alertController, animated: true, completion: nil)
    }

    static func presentSortOptions(
        on viewController: UIViewController,
        title: String?, cancelActionTitle: String,
        options: [String], selectionHandler: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(
            title: title, message: nil, preferredStyle: .actionSheet)

        for option in options {
            let action = UIAlertAction(title: option, style: .default) { _ in
                selectionHandler(option)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }
}
