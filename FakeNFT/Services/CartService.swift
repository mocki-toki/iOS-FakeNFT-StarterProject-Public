import Foundation

protocol CartServiceProtocol {
    func loadNfts(with ids: [UUID], completion: @escaping (Result<[CartItem], Error>) -> Void)
}

struct CartServiceError: Error {
    let errors: [Error]
}

final class CartService: CartServiceProtocol {
    private let nftService: NftService
    
    init(nftService: NftService) {
        self.nftService = nftService
    }
    
    func loadNfts(with ids: [UUID], completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var cartItems: [CartItem] = []
        var errors: [Error] = []
        
        for id in ids {
            dispatchGroup.enter()
            nftService.loadNft(id: id) { result in
                defer { dispatchGroup.leave() }
                
                switch result {
                case .success(let nft):
                    let imageURL = URL(string: nft.images.first ?? "")
                    cartItems.append(CartItem(
                        id: nft.id,
                        name: nft.name,
                        price: Double(round(100 * nft.price) / 100),
                        rating: nft.rating,
                        imageURL: imageURL
                    ))
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !errors.isEmpty {
                completion(.failure(CartServiceError(errors: errors)))
            } else {
                completion(.success(cartItems))
            }
        }
    }
}
