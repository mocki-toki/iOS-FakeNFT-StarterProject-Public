import UIKit

protocol MyNFTViewModelProtocol {
    var sortOptions: [String] { get }
    var onNFTsUpdated: (() -> Void)? { get set }
    
    var onLoadingStatusChanged: ((Bool) -> Void)? { get set }
    var nfts: [ProfileNft] { get set}
    func loadNFTs()
    func numberOfNFTs() -> Int
    func getNFT(at index: Int) -> ProfileNft?
    func loadImage(for nft: ProfileNft, completion: @escaping (UIImage?) -> Void)
    
    // MARK: - Sorting Methods
    
    func sortByPrice()
    func sortByRating()
    func sortByName()
    
    func applySort(option: String)
    func applySavedSort()
    
    // MARK: - Like Method
    func toggleLike(for nft: ProfileNft)
    func isLiked(nft: ProfileNft) -> Bool
    func loadLikedNFTs(completion: @escaping () -> Void)
    func loadData()
}
