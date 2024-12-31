import Foundation

struct ProfilePutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct ProfileDto: Dto {
    let likes: [UUID]?
    let avatar: URL?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case likes = "likes"
        case avatar = "avatar"
        case name = "name"
    }

    func asDictionary() -> [String: String] {
        var dict = [String: String]()
        if let likes = likes {
            dict[CodingKeys.likes.rawValue] = likes.map { $0.uuidString.lowercased() }.joined(
                separator: ",")
        }
        if let avatar = avatar {
            dict[CodingKeys.avatar.rawValue] = avatar.absoluteString
        }
        if let name = name {
            dict[CodingKeys.name.rawValue] = name
        }
        return dict
    }
}
