import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: UUID, completion: @escaping NftCompletion)
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
}
