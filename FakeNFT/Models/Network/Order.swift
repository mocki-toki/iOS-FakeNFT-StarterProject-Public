import Foundation

struct Order: Codable {
    var nfts: [UUID]
    var id: UUID
}
