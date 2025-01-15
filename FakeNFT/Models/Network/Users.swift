import Foundation

struct Users: Decodable {
    let name: String
    let avatar: String
    let rating: String
    let description: String
    let website: String
    let id: String
    let nfts: [UUID]
}
