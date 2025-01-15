import Foundation

struct ProfileNft: Decodable {
    var createdAt: String
    var name: String
    let images: [String]
    var rating: Int
    var description: String
    var price: Float
    var author: String
    let id: UUID
    
    var authorName: String {
        URL(string: author)?.host?.split(separator: ".").first.map(String.init) ?? "John Doe"
    }
    
    func formattedPrice() -> String {
        String(format: "%.2f ETH", price).replacingOccurrences(of: ".", with: ",")
    }
    
    func imageUrl() -> URL? {
        guard let firstImage = images.first else { return nil }
        Logger.log("Адрес картинки \(firstImage)")
        return URL(string: firstImage)
    }
}
