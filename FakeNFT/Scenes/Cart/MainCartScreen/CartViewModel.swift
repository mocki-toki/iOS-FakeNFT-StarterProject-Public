import Foundation

final class CartViewModel {
    // MARK: - Private Properties
    private var cartItems: [CartItem] = []
    private let sortOptionKey = "SelectedSortOption"
    private let cartService: CartServiceProtocol
    private let orderService: OrderService
    private let orderPutService: OrderPutService
    private(set) var isLoading = false
    
    @Published var isCartClearedAfterPayment: Bool = false
    
    // MARK: - Public Properties
    var onCartUpdated: (() -> Void)?
    var onLoadingStateChanged: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    var totalCost: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }
    
    var isCartEmpty: Bool {
        totalItems == 0
    }
    
    var totalItems: Int {
        cartItems.count
    }
    
    var formattedTotalItems: String {
        "\(totalItems) NFT"
    }
    
    var formattedTotalCost: String {
        String(format: "%.2f ETH", totalCost)
    }
    
    // MARK: - Initializer
    init(cartService: CartServiceProtocol, orderService: OrderService, orderPutService: OrderPutService) {
        self.cartService = cartService
        self.orderService = orderService
        self.orderPutService = orderPutService
        Logger.log("CartViewModel initialized")
        applySavedSortOption()
    }
    
    // MARK: - Public Methods
    func numberOfItems() -> Int {
        cartItems.count
    }
    
    func item(at index: Int) -> CartItem {
        cartItems[index]
    }
    
    func sortItems(by option: String) {
        saveSortOption(option)
        
        switch option {
        case String(localizable: .sortPrice):
            cartItems.sort { $0.price < $1.price }
        case String(localizable: .sortRating):
            cartItems.sort { $0.rating > $1.rating }
        case String(localizable: .sortNftName):
            cartItems.sort { $0.name < $1.name }
        default:
            Logger.log("Unknown sort option: \(option)", level: .warning)
        }
        onCartUpdated?()
    }
    
    func applySavedSortOption() {
        if let savedOption = loadSortOption() {
            Logger.log("Applying saved sort option: \(savedOption)")
            sortItems(by: savedOption)
        } else {
            Logger.log("No saved sort option found. Using default: \(String(localizable: .sortNftName))", level: .debug)
        }
    }
    
    func removeItem(_ item: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.name == item.name }) {
            Logger.log("Removing item: \(item.name) at index \(index)")
            cartItems.remove(at: index)
            onCartUpdated?()
            updateOrderWithCurrentNFTs()
        } else {
            Logger.log("Attempted to remove non-existing item: \(item.name)", level: .error)
        }
    }
    
    func loadOrderAndNfts() {
        isLoading = true
        onLoadingStateChanged?()
        
        orderService.loadOrder { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let nftIds):
                    self.loadNfts(with: nftIds)
                case .failure(let error):
                    self.isLoading = false
                    self.onLoadingStateChanged?()
                    self.onErrorOccurred?("Failed to load order: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateOrderWithCurrentNFTs() {
        let nftIds = cartItems.map { $0.id }
        orderPutService.sendOrderPutRequest(nftIds: nftIds) { result in
            switch result {
            case .success(let order):
                Logger.log("Order updated successfully: \(order.id)")
            case .failure(let error):
                Logger.log("Failed to update order: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    func clearCartAfterPayment() {
        Logger.log("Clearing cart after successful payment")
        
        orderPutService.sendOrderPutRequest(nftIds: []) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Logger.log("Cart cleared successfully")
                    self.cartItems.removeAll()
                    self.isCartClearedAfterPayment = true
                    self.onCartUpdated?()
                case .failure(let error):
                    Logger.log("Failed to clear cart: \(error.localizedDescription)", level: .error)
                }
            }
        }
    }
    
    func loadNfts(with ids: [UUID]) {
        isLoading = true
        onLoadingStateChanged?()
        
        cartService.loadNfts(with: ids) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.onLoadingStateChanged?()
                
                switch result {
                case .success(let items):
                    self.cartItems = items
                    self.onCartUpdated?()
                case .failure(let error):
                    if let cartError = error as? CartServiceError {
                        let errorMessages = cartError.errors.map { $0.localizedDescription }.joined(separator: "\n")
                        self.onErrorOccurred?("Failed to load items:\n\(errorMessages)")
                    } else {
                        self.onErrorOccurred?("Failed to load items: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func saveSortOption(_ option: String) {
        Logger.log("Saving sort option: \(option)", level: .debug)
        UserDefaults.standard.set(option, forKey: sortOptionKey)
    }
    
    private func loadSortOption() -> String? {
        return UserDefaults.standard.string(forKey: sortOptionKey) ?? String(localizable: .sortNftName)
    }
    
    func clearCart() {
        Logger.log("Clearing all items in the cart")
        cartItems.removeAll()
        onCartUpdated?()
    }
}
