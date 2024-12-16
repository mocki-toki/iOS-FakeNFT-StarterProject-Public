import Foundation

struct Nft: Decodable {
    var createdAt: String
    var name: String
    let images: [String]
    var rating: Int
    var description: String
    var price: Float
    var author: String
    let id: String
}
