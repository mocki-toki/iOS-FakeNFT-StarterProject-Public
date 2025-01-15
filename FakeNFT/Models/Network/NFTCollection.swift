import Foundation

struct NftCollection: Decodable {
    let createdAt: Date
    let name: String
    let cover: URL
    let nfts: [UUID]
    let description: String
    let author: String
    let id: UUID

    enum CodingKeys: String, CodingKey {
        case createdAt, name, cover, nfts, description, author, id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)

        let cleanedDateString = createdAtString.replacingOccurrences(of: "[GMT]", with: "")

        let formatter = DateFormatter.defaultDateFormatterWithFractionalSeconds
        guard let date = formatter.date(from: cleanedDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt, in: container,
                debugDescription: "Date string does not match format expected by formatter.")
        }
        self.createdAt = date
        self.name = try container.decode(String.self, forKey: .name)
        self.cover = try container.decode(URL.self, forKey: .cover)
        self.nfts = try container.decode([UUID].self, forKey: .nfts)
        self.description = try container.decode(String.self, forKey: .description)
        self.author = try container.decode(String.self, forKey: .author)
        self.id = try container.decode(UUID.self, forKey: .id)
    }
}
