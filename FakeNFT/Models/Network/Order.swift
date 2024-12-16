import Foundation

struct Order: Codable {
    var nfts: [String]
    var id: UUID
}
