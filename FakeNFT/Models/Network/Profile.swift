import Foundation

struct Profile: Codable {
    var name: String
    var avatar: String
    var description: String
    var website: String
    var nfts: [String]
    var likes: [String]
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatar
        case description
        case website
        case nfts
        case likes
        case id
    }
    
    func updateUserName(_ name: String) -> Profile {
        return Profile(
            name: name,
            avatar: self.avatar,
            description: self.description,
            website: self.website,
            nfts: self.nfts,
            likes: self.likes,
            id: self.id
        )
    }
    
    func updateAvatar(_ avatar: String) -> Profile {
        return Profile(
            name: self.name,
            avatar: avatar,
            description: self.description,
            website: self.website,
            nfts: self.nfts,
            likes: self.likes,
            id: self.id
        )
    }
    
    func updateUserDescription(_ description: String) -> Profile {
        return Profile(
            name: self.name,
            avatar: self.avatar,
            description: description,
            website: self.website,
            nfts: self.nfts,
            likes: self.likes,
            id: self.id
        )
    }
    
    func updateUserWebsite(_ website: String) -> Profile {
        return Profile(
            name: self.name,
            avatar: self.avatar,
            description: self.description,
            website: website,
            nfts: self.nfts,
            likes: self.likes,
            id: self.id
        )
    }
    
    func updateMyNftCount(_ count: [String]) -> Profile {
        return Profile(
            name: self.name,
            avatar: self.avatar,
            description: self.description,
            website: self.website,
            nfts: count,
            likes: self.likes,
            id: self.id
        )
    }
    
    func updateFavoriteNftCount(_ count: [String]) -> Profile {
        return Profile(
            name: self.name,
            avatar: self.avatar,
            description: self.description,
            website: self.website,
            nfts: self.nfts,
            likes: count,
            id: self.id
        )
    }
}
