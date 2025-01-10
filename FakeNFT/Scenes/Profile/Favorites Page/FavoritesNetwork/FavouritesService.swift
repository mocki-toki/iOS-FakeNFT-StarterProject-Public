import UIKit

protocol FavouritesServiceProtocol {
    func fetchFavourites(completion: @escaping (Result<[Nft], Error>) -> Void)
    func likeNFT(nftID: String,
                 completion: @escaping (Result<Bool, Error>) -> Void)
    func unlikeNFT(nftID: String,
                   completion: @escaping (Result<Bool, Error>) -> Void)
}

final class FavouritesService: FavouritesServiceProtocol {
    // MARK: - Private Properties
    private let client: NetworkClient
    private var profile: Profile?
    
    // MARK: - Initializers
    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
        downloadProfile()
    }
    
    // MARK: - Public Properties
    func fetchFavourites(completion: @escaping (Result<[Nft], Error>) -> Void) {
        let userProfileRequest = FavouritesRequest()
        client.send(request: userProfileRequest, type: Profile.self) { result in
            switch result {
            case .success(let profile):
                self.fetchFavouriteNftInfo(ids: profile.likes, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Метод для добавления NFT в избранное
    func likeNFT(nftID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard var profile = profile else {
            completion(.failure(NSError(domain: "Profile not found", code: 404, userInfo: nil)))
            return
        }
        
        if !profile.likes.contains(nftID) {
            profile.likes.append(nftID)
            updateProfileLikes(profile.likes) { result in
                switch result {
                case .success:
                    self.profile = profile
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(NSError(domain: "NFT already liked", code: 409, userInfo: nil)))
        }
    }
    
    // Метод для удаления NFT из избранного
    func unlikeNFT(nftID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard var profile = profile else {
            completion(.failure(NSError(domain: "Profile not found", code: 404, userInfo: nil)))
            return
        }
        
        if let index = profile.likes.firstIndex(of: nftID) {
            profile.likes.remove(at: index)
            updateProfileLikes(profile.likes) { result in
                switch result {
                case .success:
                    self.profile = profile
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(NSError(domain: "NFT not found in likes", code: 404, userInfo: nil)))
        }
    }
    
    private func updateProfileLikes(_ likes: [String], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let profile = profile else {
            return
        }
        
        var encodedLikes = likes.joined(separator: ",")
        if encodedLikes.isEmpty {
            encodedLikes = "null"
        }
        
        let updateDto = UpdateProfileDto(
            name: profile.name,
            description: profile.description,
            website: profile.website,
            avatar: profile.avatar,
            likes: encodedLikes
        )
        
        let request = UpdateProfileRequest(dto: updateDto)
        
        client.send(request: request, type: Profile.self) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                Logger.log("Error updating favourites: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func downloadProfile() {
        let userProfileRequest = FavouritesRequest()
        client.send(request: userProfileRequest, type: Profile.self) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                Logger.log("Успешно загружен профиль: \(profile.name)")
            case .failure(let error):
                Logger.log("Ошибка загрузки профиля: \(error)", level: .error)
            }
        }
    }
    
    private func fetchFavouriteNftInfo(ids: [String], completion: @escaping (Result<[Nft], Error>) -> Void) {
        var nfts: [Nft] = []
        let dispatchGroup = DispatchGroup()
        
        for id in ids {
            dispatchGroup.enter()
            let request = NFTRequest(id: id)
            client.send(request: request, type: Nft.self) { result in
                switch result {
                case .success(let nft):
                    nfts.append(nft)
                case .failure(let error):
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            nfts.sort { $0.price < $1.price }
            completion(.success(nfts))
        }
    }
}
