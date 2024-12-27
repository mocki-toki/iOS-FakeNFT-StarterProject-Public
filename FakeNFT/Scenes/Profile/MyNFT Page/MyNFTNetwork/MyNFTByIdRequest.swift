import Foundation

struct MyNftByIdRequest: NetworkRequest {
    // MARK: - Public Properties
    var httpMethod: HttpMethod = .get
    var dto: Dto?
    var httpBody: String?
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)") }
    
    // MARK: - Private Properties
    private let id: String
    
    // MARK: - Initializers
    init(id: String) {
        self.id = id
    }
}
