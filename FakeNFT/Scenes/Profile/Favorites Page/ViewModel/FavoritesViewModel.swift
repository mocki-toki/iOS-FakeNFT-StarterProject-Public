import UIKit
import Kingfisher

protocol FavoritesViewModelProtocol {
    var favoritesNFT: [Nft] {get set}
    var isLiked: Bool {get set}
    func numberOfFavoritesNFT() -> Int
}

final class FavoritesViewModel: FavoritesViewModelProtocol {
    var isLiked: Bool = false
    
    var favoritesNFT: [Nft] = [
        Nft(
            createdAt: "2025-01-10T12:00:00Z",
            name: "Olive Avila",
            images: [
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/1.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/2.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Bonnie/3.png"
            ],
            rating: 2,
            description: "saepe patrioque recteque doming fabellas harum libero",
            price: 21.0,
            author: "https://amazing_cerf.fakenfts.org/",
            id: "28829968-8639-4e08-8853-2f30fcf09783"
        ),
        Nft(
            createdAt: "2025-01-10T12:00:00Z",
            name: "Kieth Clarke",
            images: [
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/1.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/2.png",
                "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/3.png"
            ],
            rating: 2,
            description: "tacimates docendi efficitur tempus non quod cras pellentesque commune",
            price: 16.95,
            author: "https://goofy_napier.fakenfts.org/",
            id: "5093c01d-e79e-4281-96f1-76db5880ba70"
        )
    ]
    
    func numberOfFavoritesNFT() -> Int {
        return favoritesNFT.count
    }
}
