import Foundation

struct OrderPutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct OrderDto: Dto {
    let nftIds: [UUID]

    enum CodingKeys: String, CodingKey {
        case nfts = "nfts"
    }

    func asDictionary() -> [String: String] {
        [
            CodingKeys.nfts.rawValue: nftIds.map { $0.uuidString.lowercased() }.joined(
                separator: ",")
        ]
    }
}
