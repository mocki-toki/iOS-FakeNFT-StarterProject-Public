import UIKit
import Kingfisher

final class MyNFTViewModel: MyNFTViewModelProtocol {
    // MARK: - Public Properties
    let sortOptions = [String(localizable: .sortPrice),
                       String(localizable: .sortRating),
                       String(localizable: .sortNftName)]
    
    var onNFTsUpdated: (() -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    
    var nfts: [Nft] = [] {
        didSet {
            onNFTsUpdated?()
        }
    }
    
    // MARK: - Private Properties
    private let nftService: MyNFTServiceProtocol
    
    private var currentSortOption: String? {
        didSet {
            if let option = currentSortOption {
                UserDefaults.standard.set(option, forKey: "selectedSortOption")
            }
        }
    }
    
    // MARK: - Initializer
    
    init(nftService: MyNFTServiceProtocol) {
        self.nftService = nftService

        if let savedSortOption = UserDefaults.standard.string(forKey: "selectedSortOption") {
            self.currentSortOption = savedSortOption
        } else {
            self.currentSortOption = "По цене"
        }
    }
    
    // MARK: - Public Methods
    
    func loadNFTs() {
        onLoadingStatusChanged?(true)

        nftService.fetchNFTs { [weak self] result in
            self?.onLoadingStatusChanged?(false)
            switch result {
            case .success(let nfts):
                self?.nfts = nfts
                Logger.log("Загружены NFT \(nfts.count) шт")
            case .failure(let error):
                Logger.log("Failed to load NFTs: \(error)", level: .error)
            }
        }
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
                    completion(value.image)
                case .failure:
                    Logger.log("Загрузка картинки не удалась")
                    completion(nil)
                }
            }
        }
    
    func numberOfNFTs() -> Int {
        return nfts.count
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
        self.currentSortOption = option
        
        switch option {
        case "По цене":
            Logger.log("Сортируем по цене")
            sortByPrice()
        case "По рейтингу":
            Logger.log("Сортируем по рейтингу")
            sortByRating()
        case "По названию":
            Logger.log("Сортируем по названию")
            sortByName()
        default:
            Logger.log("Неизвестный параметр сортировки: \(option)", level: .warning)
        }
        onNFTsUpdated?()
    }
    
    func applySavedSort() {
        if let savedSortOption = currentSortOption {
            applySort(option: savedSortOption)
        }
    }
}
