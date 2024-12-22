import UIKit

protocol ProfileViewViewModelType {
    var tableItems: [ProfileTableItem] { get }
    var username: String { get }
    var bio: String { get }
    var website: String { get }
}

final class ProfileViewModel: ProfileViewViewModelType {
    // Массив для данных таблицы
    private(set) var tableItems: [ProfileTableItem] = [
        ProfileTableItem(title: "Мои NFT", count: 112, destination: MyNftViewController()),
        ProfileTableItem(title: "Избранные NFT", count: 11, destination: FavoritesViewController()),
        ProfileTableItem(title: "О разработчике",
                         count: nil,
                         destination: WebViewController(viewModel: WebViewModel(urlString: "practicum.yandex.ru")))
    ]
    
    // Данные профиля
    var username: String = "Joaquin Phoenix"
    var bio: String = """
                       Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.
                       """
    var website: String = "www.google.com"
}
