import Foundation
import Combine

struct PaymentMethod {
    let title: String
    let name: String
    let image: String
    let id: String
}

final class PaymentSelectionViewModel {
    @Published private(set) var paymentMethods: [PaymentMethod] = []
    @Published var selectedMethod: PaymentMethod?
    @Published var shouldShowSuccessScreen: Bool = false
    
    init() {
        loadPaymentMethods()
    }
    
    private func loadPaymentMethods() {
        paymentMethods = [
            PaymentMethod(title: "ApeCoin", name: "APE", image: "ApeCoin (APE)", id: "ape"),
            PaymentMethod(title: "Bitcoin", name: "BTC", image: "Bitcoin (BTC)", id: "btc"),
            PaymentMethod(title: "Cardano", name: "ADA", image: "Cardano (ADA)", id: "ada"),
            PaymentMethod(title: "Dogecoin", name: "DOGE", image: "Dogecoin (DOGE)", id: "doge"),
            PaymentMethod(title: "Ethereum", name: "ETH", image: "Ethereum (ETH)", id: "eth"),
            PaymentMethod(title: "Shiba Inu", name: "SHIB", image: "Shiba Inu (SHIB)", id: "shib"),
            PaymentMethod(title: "Solana", name: "SOL", image: "Solana (SOL)", id: "sol"),
            PaymentMethod(title: "Tether", name: "USDT", image: "Tether (USDT)", id: "usdt")
        ]
    }
    
    func selectPaymentMethod(at index: Int) {
        guard index < paymentMethods.count else { return }
        selectedMethod = paymentMethods[index]
    }
    
    func processPayment() {
        guard let selectedMethod = selectedMethod else { return }
        if selectedMethod.id == "btc" {
            shouldShowSuccessScreen = true
        }
    }
}
