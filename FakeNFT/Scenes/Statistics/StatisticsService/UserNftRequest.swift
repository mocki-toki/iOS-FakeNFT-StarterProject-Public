import Foundation

struct UserNftsRequest: NetworkRequest {
    var httpMethod: HttpMethod = .get
    var dto: Dto?
    var httpBody: String?
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/nft") }
    
    private let nftIds: [String]
    
    init(nftIds: [String]) {
        self.nftIds = nftIds
    }
}
