import Foundation

// TODO: имитация работы, заменить при мерже эпиков "профиль" и "корзина"
protocol NftStateStorage: AnyObject {
    func getNftStates() -> [UUID: NftState]
    func getNftState(with id: UUID) -> NftState?
    func toggleLikeNft(_ nft: Nft)
    func toggleCartNft(_ nft: Nft)
}

class NftState {
    var isLiked: Bool
    var isInCart: Bool

    init(isLiked: Bool, isInCart: Bool) {
        self.isLiked = isLiked
        self.isInCart = isInCart
    }
}

final class NftStateStorageImpl: NftStateStorage {
    private var storage: [UUID: NftState] = [:]

    private let syncQueue = DispatchQueue(label: "sync-nft-state-queue")

    func getNftStates() -> [UUID: NftState] {
        syncQueue.sync {
            storage
        }
    }

    func getNftState(with id: UUID) -> NftState? {
        syncQueue.sync {
            storage[id]
        }
    }

    func toggleLikeNft(_ nft: Nft) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = NftState(
                isLiked: !(self?.storage[nft.id]?.isLiked ?? false),
                isInCart: self?.storage[nft.id]?.isInCart ?? false
            )
        }
    }

    func toggleCartNft(_ nft: Nft) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = NftState(
                isLiked: self?.storage[nft.id]?.isLiked ?? false,
                isInCart: !(self?.storage[nft.id]?.isInCart ?? false)
            )
        }
    }
}
