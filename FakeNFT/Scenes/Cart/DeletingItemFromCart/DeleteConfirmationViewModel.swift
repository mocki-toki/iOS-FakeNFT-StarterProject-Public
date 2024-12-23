import UIKit

final class DeleteConfirmationViewModel {
    // MARK: - Properties
    let nftImage: UIImage
    let message: String
    let confirmButtonText: String
    let cancelButtonText: String
    
    private let onConfirm: () -> Void
    private let onCancel: () -> Void
    
    // MARK: - Initializer
    init(
        nftImage: UIImage,
        message: String,
        confirmButtonText: String = String(localizable: .cartDelete),
        cancelButtonText: String = String(localizable: .cartReturn),
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.nftImage = nftImage
        self.message = message
        self.confirmButtonText = confirmButtonText
        self.cancelButtonText = cancelButtonText
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    // MARK: - Public Methods
    func confirmDeletion() {
        onConfirm()
    }
    
    func cancelDeletion() {
        onCancel()
    }
}
