import Foundation

final class CartViewModel {
    // MARK: - Private Properties
    private var cartItems: [CartItem] = []
    private let sortOptionKey = "SelectedSortOption"
    
    // MARK: - Public Properties
    var onCartUpdated: (() -> Void)?
    
    var totalCost: Double {
        cartItems.reduce(0) { $0 + ($1.isInCart ? $1.price : 0) }
    }
    
    var isCartEmpty: Bool {
        totalItems == 0
    }
    
    var totalItems: Int {
        cartItems.filter { $0.isInCart }.count
    }
    
    var formattedTotalItems: String {
        "\(totalItems) NFT"
    }
    
    var formattedTotalCost: String {
        String(format: "%.2f ETH", totalCost)
    }
    
    // MARK: - Initializer
    init(items: [CartItem]) {
        self.cartItems = items
        Logger.log("CartViewModel initialized with \(items.count) items")
        applySavedSortOption()
    }
    
    // MARK: - Public Methods
    func numberOfItems() -> Int {
        cartItems.count
    }
    
    func item(at index: Int) -> CartItem {
        cartItems[index]
    }
    
    func toggleCartState(for index: Int) {
        cartItems[index].isInCart.toggle()
        Logger.log("Toggled cart state for item: \(cartItems[index].name). Now in cart: \(cartItems[index].isInCart)", level: .debug)
        onCartUpdated?()
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
            break
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
        } else {
            Logger.log("Attempted to remove non-existing item: \(item.name)", level: .error)
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
}
