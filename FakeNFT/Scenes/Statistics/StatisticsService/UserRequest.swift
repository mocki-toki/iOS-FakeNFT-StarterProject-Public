import Foundation

struct UserRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users")
    }
    
    var httpMethod: HttpMethod = .get
    var dto: Dto? = nil
}
