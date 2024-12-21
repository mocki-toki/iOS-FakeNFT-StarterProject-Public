import Foundation

struct CurrenciesRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
    var httpMethod: HttpMethod = .get
    var dto: Dto? = nil
}
