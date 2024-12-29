import Foundation

protocol NftCollectionStorage: AnyObject {
    func saveCollections(_ collections: [NftCollection])
    func getCollections() -> [NftCollection]?
    func getCollection(byId id: UUID) -> NftCollection?
    func saveCollection(_ collection: NftCollection)
}

final class NftCollectionStorageImpl: NftCollectionStorage {
    private var storage: [NftCollection]?
    private var cacheById: [UUID: NftCollection] = [:]
    private let syncQueue = DispatchQueue(
        label: "sync-nft-collection-queue", attributes: .concurrent)

    func saveCollections(_ collections: [NftCollection]) {
        syncQueue.async(flags: .barrier) { [weak self] in
            self?.storage = collections

            for collection in collections {
                self?.cacheById[collection.id] = collection
            }
            Logger.log("Collections have been saved and cached by ID.")
        }
    }

    func getCollections() -> [NftCollection]? {
        syncQueue.sync {
            return storage
        }
    }

    func getCollection(byId id: UUID) -> NftCollection? {
        syncQueue.sync {
            if let cached = cacheById[id] {
                Logger.log("Retrieved collection from cache.")
                return cached
            }
            let collection = storage?.first { $0.id == id }
            if let collection = collection {
                cacheById[id] = collection
                Logger.log("Collection cached after retrieval.")
            }
            return collection
        }
    }

    func saveCollection(_ collection: NftCollection) {
        syncQueue.async(flags: .barrier) { [weak self] in
            if var existingStorage = self?.storage {
                if let index = existingStorage.firstIndex(where: { $0.id == collection.id }) {
                    existingStorage[index] = collection
                } else {
                    existingStorage.append(collection)
                }
                self?.storage = existingStorage
            } else {
                self?.storage = [collection]
            }
            self?.cacheById[collection.id] = collection
            Logger.log("Single collection has been saved and cached by ID.")
        }
    }
}
