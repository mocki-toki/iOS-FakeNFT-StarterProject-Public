import Foundation

struct NftDetailsModel {
    let id: UUID
    let images: [String]
    let name: String
    let rating: Int
    let collectionName: String
    let price: Float
    let authorSiteUrl: URL
    let currencies: [NftDetailsCurrencyModel]
}
