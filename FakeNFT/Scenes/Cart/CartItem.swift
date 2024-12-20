import UIKit

// MARK: - Модель для элемента корзины
struct CartItem {
    let name: String
    let price: Double
    let rating: Int
    let image: UIImage
    var isInCart: Bool
}
