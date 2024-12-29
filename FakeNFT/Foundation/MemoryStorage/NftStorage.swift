import Foundation

protocol NftStorage: AnyObject {
    func saveNft(_ nft: Nft)
    func getNft(with id: UUID) -> Nft?
}

// Пример простого класса, который сохраняет данные из сети
final class NftStorageImpl: NftStorage {
    private var storage: [UUID: Nft] = [:]

    private let syncQueue = DispatchQueue(label: "sync-nft-queue")

    func saveNft(_ nft: Nft) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = nft
        }
    }

    func getNft(with id: UUID) -> Nft? {
        syncQueue.sync {
            storage[id]
        }
    }
}
