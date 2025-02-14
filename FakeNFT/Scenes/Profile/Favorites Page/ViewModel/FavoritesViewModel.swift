import UIKit
import Kingfisher

protocol FavouritesViewModelProtocol {
    var favouritesNfts: [ProfileNft] { get set }
    var onLoadingStatusChanged: ((Bool) -> Void)? { get set }
    var onFavouritesNFTsUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadFavouritesNFTs()
    func unlikeNFT(at index: Int)
    func getFavouriteNFT(at index: Int) -> ProfileNft?
    func numberOfFavouritesNFTs() -> Int
}

final class FavouritesViewModel: FavouritesViewModelProtocol {
    // MARK: - Public Properties
    var favouritesNfts: [ProfileNft] = [] {
        didSet {
            Logger.log("onFavouritesNFTsUpdated вызван")
            onFavouritesNFTsUpdated?()
        }
    }
    var onLoadingStatusChanged: ((Bool) -> Void)?
    var onFavouritesNFTsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let favouritesService: FavouritesServiceProtocol
    
    // MARK: - Initializers
    init(favouritesService: FavouritesService = FavouritesService()) {
        self.favouritesService = favouritesService
    }
    
    // MARK: - Methods
    func loadFavouritesNFTs() {
        Logger.log("loadFavouritesNFTs вызван")
        self.onLoadingStatusChanged?(true)

        self.favouritesService.downloadProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Logger.log("Профиль загружен. Загружаем избранные NFT.")
                    self?.fetchFavouritesNFTs()
                    
                case .failure(let error):
                    Logger.log("Ошибка загрузки профиля: \(error)", level: .error)
                    self?.onLoadingStatusChanged?(false)
                    self?.onError?("Не удалось загрузить профиль. Попробуйте снова.")
                }
            }
        }
    }
    
    private func fetchFavouritesNFTs() {
        Logger.log("fetchFavouritesNFTs вызван")
        self.favouritesService.fetchFavourites { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStatusChanged?(false)
                switch result {
                case .success(let nfts):
                    self?.favouritesNfts = nfts
                    Logger.log("Загружены \(nfts.count) NFT")
                case .failure(let error):
                    Logger.log("Ошибка загрузки избранных NFT \(error)", level: .error)
                    self?.onError?("Не удалось загрузить избранные NFT. Попробуйте снова.")
                }
            }
        }
    }
    
    func unlikeNFT(at index: Int) {
        guard index >= 0 && index < favouritesNfts.count else { return }
        let nft = favouritesNfts[index]
        
        favouritesService.unlikeNFT(nftID: nft.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success {
                        self?.favouritesNfts.remove(at: index)
                        Logger.log("Удалено из избранного \(nft.name) \(nft.id)")
                    } else {
                        Logger.log("Ошибка удаления из Избранного ID: \(nft.id)", level: .error)
                        self?.onError?("Не удалось удалить NFT из избранного. Попробуйте снова.")
                    }
                case .failure(let error):
                    Logger.log("Ошибка при удалении из избранного: \(error)", level: .error)
                    self?.onError?("Не удалось удалить NFT из избранного. Попробуйте снова.")
                }
            }
        }
    }
    
    func getFavouriteNFT(at index: Int) -> ProfileNft? {
        guard index >= 0 && index < favouritesNfts.count else { return nil }
        return favouritesNfts[index]
    }
    
    func numberOfFavouritesNFTs() -> Int {
        return favouritesNfts.count
    }
}
