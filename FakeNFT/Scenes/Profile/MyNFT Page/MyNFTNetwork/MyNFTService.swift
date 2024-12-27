import UIKit

protocol MyNFTServiceProtocol {
    func fetchNFTs(completion: @escaping (Result<[Nft], Error>) -> Void)
}

final class MyNFTService: MyNFTServiceProtocol {
    // MARK: - Private Properties
    private let client: NetworkClient
    
    // MARK: - Initializers
    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
    }
    
    // MARK: - Public Properties
    func fetchNFTs(completion: @escaping (Result<[Nft], Error>) -> Void) {
        fetchNftsIDInProfile { [weak self] result in
            switch result {
            case .success(let nftsInMyProfile):
                self?.fetchMyNFTs(nftsInMyProfile: nftsInMyProfile) { result in
                    self?.handleResult(result, completion: completion)
                }
            case .failure(let error):
                self?.handleResult(.failure(error), completion: completion)
            }
        }
    }
    
    // MARK: - Private Methods
    private func handleResult<T>(
        _ result: Result<T, Error>,
        completion: @escaping (Result<T, Error>
        ) -> Void) {
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private func fetchNftsIDInProfile(
        _ completion: @escaping (Result<MyNFTOrderModel, Error>) -> Void
    ) {
        let request = ProfileRequest()
        client.send(request: request, type: MyNFTOrderModel.self) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    private func fetchMyNFTs(
        nftsInMyProfile: MyNFTOrderModel,
        _ completion: @escaping (Result<[Nft], Error>) -> Void
    ) {
        var nftItems: [Nft] = []
        let dispatchGroup = DispatchGroup()
        
        let nfts: [String] = nftsInMyProfile.nfts
        
        for item in nfts {
            dispatchGroup.enter()
            client.send(request: MyNftByIdRequest(id: item), type: Nft.self) { result in
                switch result {
                case .success(let nftItem):
                    nftItems.append(nftItem)
                case .failure(let error):
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(nftItems))
        }
    }
}
