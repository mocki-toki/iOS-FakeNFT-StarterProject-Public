import Foundation

struct UpdateProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct UpdateProfileDto: Dto {
    let name: String
    let description: String
    let website: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case website
        case avatar
    }
    
    func asDictionary() -> [String : String] {
        [
            CodingKeys.name.rawValue: name,
            CodingKeys.description.rawValue: description,
            CodingKeys.website.rawValue: website,
            CodingKeys.avatar.rawValue: avatar
        ]
    }
}
