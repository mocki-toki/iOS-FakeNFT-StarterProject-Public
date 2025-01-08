import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func loadUserNfts(id: String, completion: @escaping NftsCompletion)
    func loadUserDetails(userId: String, completion: @escaping UserDetailsCompletion)
}

final class NftServiceImpl: NftService {
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }
        
        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
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
}
