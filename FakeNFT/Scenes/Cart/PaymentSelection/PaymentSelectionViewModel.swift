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
    @Published var fetchPaymentMethodsResult: FetchPaymentMethodsResult?
    @Published var setCurrencyResult: SetCurrencyResult?
    @Published var shouldCloseScreen: Bool = false
    
    enum SetCurrencyResult {
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
                        imageUrl:  currency.image,
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
        guard let selectedMethod = selectedMethod else {
            Logger.log("No payment method selected", level: .error)
            return
        }
        
        isLoading = true
        currenciesService.setCurrencyForTheOrder(id: selectedMethod.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    Logger.log("Payment successful")
                    self.setCurrencyResult = .success
                case .failure(let error):
                    Logger.log("Payment failed: \(error.localizedDescription)", level: .error)
                    self.setCurrencyResult = .failure
                }
            }
        }
    }
}
