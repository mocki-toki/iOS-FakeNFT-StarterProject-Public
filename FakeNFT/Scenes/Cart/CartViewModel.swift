import Foundation

final class CartViewModel {
    // MARK: - Private Properties
    private var cartItems: [CartItem] = []
    
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
        onCartUpdated?()
    }
    
    func sortItems(by option: String) {
        switch option {
        case String(localizable: .sortPrice):
            cartItems.sort { $0.price < $1.price }
        case String(localizable: .sortRating):
            cartItems.sort { $0.rating > $1.rating }
        case String(localizable: .sortNftName):
            cartItems.sort { $0.name < $1.name }
        default:
            break
        }
        onCartUpdated?()
    }
}
