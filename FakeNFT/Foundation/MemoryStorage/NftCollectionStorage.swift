import Foundation

protocol NftCollectionStorage: AnyObject {
    func saveCollections(_ collections: [NftCollection])
    func getCollections() -> [NftCollection]?
}

final class NftCollectionStorageImpl: NftCollectionStorage {
    private var storage: [NftCollection]?
    private let syncQueue = DispatchQueue(
        label: "sync-nft-collection-queue", attributes: .concurrent)

    func saveCollections(_ collections: [NftCollection]) {
        syncQueue.async(flags: .barrier) { [weak self] in
            self?.storage = collections
        }
    }

    func getCollections() -> [NftCollection]? {
        syncQueue.sync {
            return storage
        }
    }
}
