import Foundation

struct NFTRequest: NetworkRequest {
    let id: UUID
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id.uuidString.lowercased())")
    }
    var dto: Dto?
}
