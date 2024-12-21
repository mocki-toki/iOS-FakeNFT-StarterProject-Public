import UIKit

final class ProfileViewModel {
    // Массив для данных таблицы
    private(set) var tableItems: [ProfileTableItem] = [
        ProfileTableItem(title: "Мои NFT", count: 112, destination: TestViewController()),
        ProfileTableItem(title: "Избранные NFT", count: 11, destination: TestViewController()),
        ProfileTableItem(title: "О разработчике", count: 3, destination: TestViewController())
    ]
    
    // Данные профиля
    var username: String = "Joaquin Phoenix"
    var bio: String = """
                       Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.
                       """
    var website: String = "www.mysite.com"
}
