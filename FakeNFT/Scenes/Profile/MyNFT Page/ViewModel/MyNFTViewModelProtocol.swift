import UIKit

protocol MyNFTViewModelProtocol {
    var sortOptions: [String] { get }
    var onNFTsUpdated: (() -> Void)? { get set }
    
    var onLoadingStatusChanged: ((Bool) -> Void)? { get set }
    var nfts: [Nft] { get set}
    func loadNFTs()
    func numberOfNFTs() -> Int
    func getNFT(at index: Int) -> Nft?
    func loadImage(for nft: Nft, completion: @escaping (UIImage?) -> Void)
    
    // MARK: - Sorting Methods
    
    func sortByPrice()
    func sortByRating()
    func sortByName()
    
    func applySort(option: String)
    func applySavedSort()
    
    // MARK: - Like Method
    func toggleLike(for nft: Nft)
    func isLiked(nft: Nft) -> Bool
    func loadLikedNFTs(completion: @escaping () -> Void)
    func loadData()
}
