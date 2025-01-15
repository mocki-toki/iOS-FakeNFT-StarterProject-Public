import Foundation

struct NFTCollectionByIdRequest: NetworkRequest {
    let id: UUID
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(id.uuidString.lowercased())")
    }
    var dto: Dto?
}
