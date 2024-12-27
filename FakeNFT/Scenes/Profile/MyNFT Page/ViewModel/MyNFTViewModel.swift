import UIKit

final class MyNFTViewModel: MyNFTViewModelProtocol {
    // MARK: - Public Properties
    let sortOptions = [String(localizable: .sortPrice),
                       String(localizable: .sortRating),
                       String(localizable: .sortNftName)]
    
    private var currentSortOption: String? {
        didSet {
            if let option = currentSortOption {
                UserDefaults.standard.set(option, forKey: "selectedSortOption")
            }
        }
    }
    
    var onNFTsUpdated: (() -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    
    var nfts: [Nft] = [] {
        didSet {
            onNFTsUpdated?()
        }
    }
                       
    func addNFTs(_ newNFTs: [Nft]) {
        self.nfts.append(contentsOf: newNFTs)
        onNFTsUpdated?()
    }
    
    // MARK: - Private Properties
    
    // MARK: - Initializer
    
    init() {
        // Загружаем сохранённый параметр сортировки при инициализации
        if let savedSortOption = UserDefaults.standard.string(forKey: "selectedSortOption") {
            self.currentSortOption = savedSortOption
        } else {
            self.currentSortOption = "По цене"
        }
    }
    // MARK: - Public Methods
    
    func getNFT(at index: Int) -> Nft? {
        guard index >= 0 && index < nfts.count else { return nil }
        return nfts[index]
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
            print("Сортируем по цене")
            sortByPrice()
        case "По рейтингу":
            print("Сортируем по рейтингу")
            sortByRating()
        case "По названию":
            print("Сортируем по названию")
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
