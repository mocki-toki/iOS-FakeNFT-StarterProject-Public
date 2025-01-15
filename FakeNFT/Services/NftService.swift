import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol NftService {
    func loadUserNfts(id: String, completion: @escaping NftsCompletion)
    func loadUserDetails(userId: String, completion: @escaping UserDetailsCompletion)
    func loadNft(id: UUID, completion: @escaping NftCompletion)
    func loadNfts(ids: [UUID], completion: @escaping (Result<[CartItem], Error>) -> Void)
}

struct NftServiceError: Error {
    let errors: [Error]
}

final class NftServiceImpl: NftService {
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    func loadNft(id: UUID, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            Logger.log("Cache hit: NFT with ID \(id) found in storage.", level: .debug)
            completion(.success(nft))
            return
        }
        
        let request = NFTRequest(id: id)
        Logger.log("Sending request to: \(request.endpoint?.absoluteString ?? "Invalid URL")")
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                Logger.log("Request successful for ID \(id). NFT: \(nft)", level: .info)
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                Logger.log("Request failed for ID \(id). Error: \(error)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    func loadUserNfts(id: String, completion: @escaping NftsCompletion) {
        let request = UserNftsRequest(nftIds: [id])
        networkClient.send(request: request, type: [Nft].self, completionQueue: .main) { result in
            completion(result)
        }
    }
    
    func loadUserDetails(userId: String, completion: @escaping UserDetailsCompletion) {
        let request = UserRequest(userId: userId)
        networkClient.send(request: request, type: Users.self, completionQueue: .main) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func loadNfts(ids: [UUID], completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var cartItems: [CartItem] = []
        var errors: [Error] = []
        
        for id in ids {
            Logger.log("Processing NFT with ID: \(id)", level: .debug)
            dispatchGroup.enter()
            loadNft(id: id) { result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let nft):
                    let imageURL = URL(string: nft.images.first ?? "")
                    let cartItem = CartItem(
                        id: nft.id,
                        name: nft.name,
                        price: Double(round(100 * nft.price) / 100),
                        rating: nft.rating,
                        imageURL: imageURL
                    )
                    cartItems.append(cartItem)
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !errors.isEmpty {
                completion(.failure(NftServiceError(errors: errors)))
            } else {
                completion(.success(cartItems))
            }
        }
    }
}
