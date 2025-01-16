import Foundation

final class SuccessViewModel {
    // MARK: - Public Properties
    let successData: SuccessModel

    init() {
        successData = SuccessModel(
            imageName: "SucessfulPayment",
            message: String(localizable: .paymentSuccess),
            buttonText: String(localizable: .paymentReturnToCart)
        )
    }
}
