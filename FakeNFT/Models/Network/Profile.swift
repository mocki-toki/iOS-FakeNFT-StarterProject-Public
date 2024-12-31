import Foundation

struct Profile: Codable {
    var name: String
    var avatar: URL
    var description: String
    var website: URL
    var nfts: [UUID]
    var likes: [UUID]
    let id: UUID
}
