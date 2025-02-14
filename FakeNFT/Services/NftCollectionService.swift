import Foundation

typealias NftCollectionCompletion = (Result<[NftCollection], Error>) -> Void
typealias NftCollectionByIdCompletion = (Result<NftCollection, Error>) -> Void

protocol NftCollectionService {
    func loadCollections(completion: @escaping NftCollectionCompletion)
    func loadCollectionById(id: UUID, completion: @escaping NftCollectionByIdCompletion)
}

final class NftCollectionServiceImpl: NftCollectionService {
    private let networkClient: NetworkClient
    private let storage: NftCollectionStorage

    init(networkClient: NetworkClient, storage: NftCollectionStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadCollections(completion: @escaping NftCollectionCompletion) {
        if let collections = storage.getCollections() {
            completion(.success(collections))
            return
        }

        let request = NFTCollectionsRequest()
        networkClient.send(request: request, type: [NftCollection].self) { [weak storage] result in
            switch result {
            case .success(let collections):
                storage?.saveCollections(collections)
                completion(.success(collections))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadCollectionById(id: UUID, completion: @escaping NftCollectionByIdCompletion) {
        let request = NFTCollectionByIdRequest(id: id)
        networkClient.send(request: request, type: NftCollection.self) { [weak storage] result in
            switch result {
            case .success(let collection):
                storage?.saveCollection(collection)
                completion(.success(collection))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
