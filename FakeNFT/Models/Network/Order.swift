import Foundation

struct Order: Codable {
    let nfts: [UUID]
    let id: UUID
}
