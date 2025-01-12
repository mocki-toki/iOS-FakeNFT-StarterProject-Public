import UIKit
import Kingfisher

// MARK: - Enum SortOption
enum SortOption: String, CaseIterable {
    case price
    case rating
    case nftName
    
    var localized: String {
        switch self {
        case .price:
            return String(localizable: .sortPrice)
        case .rating:
            return String(localizable: .sortRating)
        case .nftName:
            return String(localizable: .sortNftName)
        }
    }
}

final class MyNFTViewModel: MyNFTViewModelProtocol {
    // MARK: - Public Properties
    let sortOptions: [String] = SortOption.allCases.map { $0.localized }
    
    var onNFTsUpdated: (() -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    var nfts: [Nft] = [] {
        didSet {
            onNFTsUpdated?()
        }
    }
    
    private var likedNFTs: [String] = []
    private var profileLoaded: Bool = false
    private var isLikedNFTsLoaded = false
    
    // MARK: - Private Properties
    private let nftService: MyNFTServiceProtocol
    private let favouritesService: FavouritesServiceProtocol
    
    private var currentSortOption: SortOption? {
        didSet {
            if let option = currentSortOption {
                UserDefaults.standard.set(option.rawValue, forKey: "selectedSortOption")
            }
        }
    }
    
    // MARK: - Initializer
    
    init(nftService: MyNFTServiceProtocol, favouritesService: FavouritesServiceProtocol) {
        self.nftService = nftService
        self.favouritesService = favouritesService

        if let savedSortOption = UserDefaults.standard.string(forKey: "selectedSortOption"),
           let savedOption = SortOption(rawValue: savedSortOption) {
            self.currentSortOption = savedOption
        } else {
            self.currentSortOption = .rating
        }
    }
    
    // MARK: - Public Methods
    
    func loadNFTs() {
        nftService.fetchMyNFTs { [weak self] result in
            self?.onLoadingStatusChanged?(false)
            switch result {
            case .success(let nfts):
                self?.nfts = nfts
                Logger.log("Загружены NFT \(nfts.count) шт")
                DispatchQueue.main.async {
                    self?.onNFTsUpdated?()
                }
            case .failure(let error):
                Logger.log("Не удалось загрузить NFT.: \(error)", level: .error)
            }
        }
    }
    
    func loadLikedNFTs(completion: @escaping () -> Void) {
        Logger.log("loadLikedNFTs вызван")
        downloadProfile { [weak self] result in
            switch result {
            case .success:
                self?.favouritesService.fetchFavourites { [weak self] result in
                    switch result {
                    case .success(let likedNfts):
                        self?.likedNFTs = likedNfts.map { $0.id }
                        self?.onNFTsUpdated?()
                        Logger.log("Liked \(likedNfts.count)")
                        completion()
                    case .failure(let error):
                        Logger.log("Не удалось загрузить избранное: \(error)")
                        completion()
                    }
                }
            case .failure(let error):
                Logger.log("Ошибка при загрузке профиля: \(error)", level: .error)
                completion()
            }
        }
    }
    
    func loadData() {
        onLoadingStatusChanged?(true)

        loadLikedNFTs { [weak self] in
            self?.loadNFTs()
        }
    }
    
    func toggleLike(for nft: Nft) {
        guard profileLoaded else {
            Logger.log("Профиль не загружен, не могу изменить лайк для NFT", level: .error)
            return
        }
        
        if likedNFTs.contains(nft.id) {
            // Удаление лайка
            favouritesService.unlikeNFT(nftID: nft.id) { [weak self] result in
                switch result {
                case .success:
                    self?.likedNFTs.removeAll { $0 == nft.id }
                    Logger.log("Лайк удален для NFT с ID: \(nft.id)")
                    self?.onNFTsUpdated?()
                case .failure(let error):
                    Logger.log("Ошибка при удалении лайка: \(error)", level: .error)
                }
            }
        } else {
            // Добавление лайка
            favouritesService.likeNFT(nftID: nft.id) { [weak self] result in
                switch result {
                case .success:
                    self?.likedNFTs.append(nft.id)
                    Logger.log("Лайк добавлен для NFT с ID: \(nft.id)")
                    self?.onNFTsUpdated?()
                case .failure(let error):
                    Logger.log("Ошибка при добавлении лайка: \(error)", level: .error)
                }
            }
        }
    }

    func isLiked(nft: Nft) -> Bool {
        return likedNFTs.contains(nft.id)
    }
    
    func getNFT(at index: Int) -> Nft? {
        guard index >= 0 && index < nfts.count else { return nil }
        return nfts[index]
    }
    
    func loadImage(for nft: Nft, completion: @escaping (UIImage?) -> Void) {
        guard let url = nft.imageUrl() else {
            completion(nil)
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    completion(value.image)
                }
            case .failure:
                Logger.log("Загрузка картинки не удалась")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func numberOfNFTs() -> Int {
        return nfts.count
    }
    
    // MARK: - Profile Loading

    func downloadProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        favouritesService.downloadProfile { [weak self] result in
            switch result {
            case .success:
                self?.profileLoaded = true
                Logger.log("Профиль успешно загружен")
                completion(.success(()))
            case .failure(let error):
                Logger.log("Ошибка при загрузке профиля: \(error)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sorting Methods
    
    func sortByPrice() {
        nfts.sort { $0.price < $1.price }
    }
    
    func sortByRating() {
        nfts.sort { $0.rating > $1.rating }
    }
    
    func sortByName() {
        nfts.sort { $0.name < $1.name }
    }
    
    func applySort(option: String) {
        guard let selectedOption = SortOption.allCases.first(where: { $0.localized == option }) else {
            Logger.log("Неизвестный параметр сортировки: \(option)", level: .warning)
            return
        }
        
        self.currentSortOption = selectedOption
        
        switch selectedOption {
        case .price:
            Logger.log("Сортируем по цене")
            sortByPrice()
        case .rating:
            Logger.log("Сортируем по рейтингу")
            sortByRating()
        case .nftName:
            Logger.log("Сортируем по названию")
            sortByName()
        }
        
        onNFTsUpdated?()
    }
    
    func applySavedSort() {
        if let savedSortOption = currentSortOption {
            applySort(option: savedSortOption.localized)
        }
    }
}
