import Foundation

enum CollectionListState {
    case initial, loading
    case failed(Error)
    case data([NftCollection])
}

protocol CollectionListViewModel {
    var stateDidChanged: ((CollectionListState) -> Void)? { get set }
    func fetchCollections()
    func didSelectCollection(id collectionId: UUID)
}

final class CollectionListViewModelImpl: CollectionListViewModel {
    private let nftCollectionService: NftCollectionService
    private var state = CollectionListState.initial {
        didSet {
            stateDidChanged?(state)
        }
    }

    var stateDidChanged: ((CollectionListState) -> Void)?

    init(nftCollectionService: NftCollectionService) {
        self.nftCollectionService = nftCollectionService
    }

    func fetchCollections() {
        state = .loading
        nftCollectionService.loadCollections { [weak self] result in
            switch result {
            case .success(let collections):
                self?.state = .data(collections)
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    func didSelectCollection(id collectionId: UUID) {
        // TODO: Implement
    }
}
