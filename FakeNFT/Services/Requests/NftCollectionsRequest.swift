import Foundation

struct NFTCollectionsRequest: NetworkRequest {
    var dto: (any Dto)?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }

    var httpMethod: HttpMethod {
        return .get
    }
}
