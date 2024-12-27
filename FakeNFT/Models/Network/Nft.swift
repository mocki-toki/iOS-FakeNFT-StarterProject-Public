import Foundation

struct Nft: Decodable {
    var createdAt: String
    var name: String
    let images: [String]
    var rating: Int
    var description: String
    var price: Float
    var author: String
    let id: String
    
    var authorName: String {
        URL(string: author)?.host?.split(separator: ".").first.map(String.init) ?? "John Doe"
    }
    
    func formattedPrice() -> String {
        return String(format: "%.2f ETH", price).replacingOccurrences(of: ".", with: ",")
    }
}
