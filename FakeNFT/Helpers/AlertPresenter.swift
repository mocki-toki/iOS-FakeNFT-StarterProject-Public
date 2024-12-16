import UIKit

// MARK: - Alert Presenter
final class AlertPresenter {
    
    static func presentAlertWithOneButton(on viewController: UIViewController, title: String?, message: String?, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .cancel, handler: nil)
        alertController.addAction(action)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
 
    static func presentAlertWithTwoButtons(on viewController: UIViewController, title: String?, message: String?, firstButtonTitle: String, secondButtonTitle: String, firstAction: (() -> Void)?, secondAction: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default) { _ in
            firstAction?()
        }
        alertController.addAction(firstAction)
        
        let secondAction = UIAlertAction(title: secondButtonTitle, style: .default) { _ in
            secondAction?()
        }
        alertController.addAction(secondAction)
        alertController.preferredAction = secondAction
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func presentSortOptions(on viewController: UIViewController, title: String?, message: String?, cancelActionTitle: String, options: [String], selectionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

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



