import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
         URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
     }

     var httpMethod: HttpMethod = .get
     var dto: Dto?
}
