import Foundation

struct Nft: Decodable {
    var createdAt: Date
    var name: String
    let images: [URL]
    var rating: Int
    var description: String
    var price: Float
    var author: String
    let id: UUID
}
