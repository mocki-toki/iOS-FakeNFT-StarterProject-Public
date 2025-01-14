import Foundation

struct UserRequest: NetworkRequest {
    var userId: String?
    var endpoint: URL? {
        if let userId = userId {
            return URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(userId)")
        }
        return URL(string: "\(RequestConstants.baseURL)/api/v1/users")
    }
    var httpMethod: HttpMethod = .get
    var dto: Dto?
}
