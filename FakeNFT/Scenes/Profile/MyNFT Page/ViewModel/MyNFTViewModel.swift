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
    var isLiked: Bool = false
    var nfts: [Nft] = [] {
        didSet {
            onNFTsUpdated?()
        }
    }
    
    // MARK: - Private Properties
    private let nftService: MyNFTServiceProtocol
    
    private var currentSortOption: SortOption? {
        didSet {
            if let option = currentSortOption {
                UserDefaults.standard.set(option.rawValue, forKey: "selectedSortOption")
            }
        }
    }
    
    // MARK: - Initializer
    
    init(nftService: MyNFTServiceProtocol) {
        self.nftService = nftService

        if let savedSortOption = UserDefaults.standard.string(forKey: "selectedSortOption"),
           let savedOption = SortOption(rawValue: savedSortOption) {
            self.currentSortOption = savedOption
        } else {
            self.currentSortOption = .rating
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
                DispatchQueue.main.async {
                    self?.onNFTsUpdated?()
                }
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
