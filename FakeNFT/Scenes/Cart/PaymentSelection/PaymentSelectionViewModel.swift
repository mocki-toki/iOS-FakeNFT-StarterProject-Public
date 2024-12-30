import Foundation
import Combine

struct PaymentMethod {
    let title: String
    let name: String
    let imageUrl: URL?
    let id: String
}

final class PaymentSelectionViewModel {
    private let currenciesService: CurrenciesService
    private var timeoutWorkItem: DispatchWorkItem?
    
    @Published private(set) var paymentMethods: [PaymentMethod] = []
    @Published var selectedMethod: PaymentMethod?
    @Published var isLoading: Bool = false
    @Published var paymentResult: PaymentResult?
    @Published var fetchPaymentMethodsResult: FetchPaymentMethodsResult?
    @Published var shouldCloseScreen: Bool = false
    
    enum PaymentResult {
        case success
        case failure
    }
    
    enum FetchPaymentMethodsResult {
        case success
        case failure
    }
    
    init(currenciesService: CurrenciesService) {
        self.currenciesService = currenciesService
        loadPaymentMethods()
    }
    
    func processOpeningCartView() {
        shouldCloseScreen = true
    }
    
    func loadPaymentMethods() {
        isLoading = true
        fetchPaymentMethodsResult = nil
        
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                self.isLoading = false
                self.fetchPaymentMethodsResult = .failure
                Logger.log("Request timed out after 10 seconds")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutWorkItem!)
        
        currenciesService.fetchCurrencies { [weak self] result in
            guard let self = self else { return }
            self.timeoutWorkItem?.cancel()
            self.isLoading = false
            switch result {
            case .success(let currencies):
                self.paymentMethods = currencies.map { currency in
                    PaymentMethod(
                        title: currency.title,
                        name: currency.name,
                        imageUrl: URL(string: currency.image),
                        id: currency.id
                    )
                }
                self.fetchPaymentMethodsResult = .success
            case .failure(let error):
                self.fetchPaymentMethodsResult = .failure
                Logger.log("Failed to fetch currencies: \(error)")
            }
        }
    }
    
    func selectPaymentMethod(at index: Int) {
        guard index < paymentMethods.count else { return }
        selectedMethod = paymentMethods[index]
    }
    
    func processPayment() {
        guard let selectedMethod = selectedMethod else { return }
        if selectedMethod.id == "btc" {
            paymentResult = .success
        } else {
            paymentResult = .failure
        }
    }
}
