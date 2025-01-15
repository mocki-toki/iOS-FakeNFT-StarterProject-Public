import Foundation

struct Nft: Decodable {
    let createdAt: Date
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Float
    let author: String
    let id: UUID

enum CodingKeys: String, CodingKey {
    case createdAt, name, images, rating, description, price, author, id
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
    self.images = try container.decode([String].self, forKey: .images)
    self.rating = try container.decode(Int.self, forKey: .rating)
    self.description = try container.decode(String.self, forKey: .description)
    self.price = try container.decode(Float.self, forKey: .price)
    self.author = try container.decode(String.self, forKey: .author)
    self.id = try container.decode(UUID.self, forKey: .id)
}
}
