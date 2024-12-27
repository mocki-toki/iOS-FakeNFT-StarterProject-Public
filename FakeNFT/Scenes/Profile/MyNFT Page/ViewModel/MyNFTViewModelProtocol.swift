import UIKit

protocol MyNFTViewModelProtocol {
    var sortOptions: [String] { get }
    var onNFTsUpdated: (() -> Void)? { get set }
    
    var onLoadingStatusChanged: ((Bool) -> Void)? { get set }
    
    var nfts: [Nft] { get set}
    func addNFTs(_ newNFTs: [Nft])
    
    func numberOfNFTs() -> Int
    func getNFT(at index: Int) -> Nft?
    
    func sortByPrice()
    func sortByRating()
    func sortByName()
    
    // MARK: - Sorting Methods
    func applySort(option: String)
    func applySavedSort()
}
