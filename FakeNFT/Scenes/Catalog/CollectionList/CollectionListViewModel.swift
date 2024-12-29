import Foundation

enum CollectionListState {
    case initial, loading
    case failed(Error)
    case data([NftCollection])
}

enum CollectionListSortType {
    case name
    case nftsCount
}

protocol CollectionListViewModel {
    var stateDidChanged: ((CollectionListState) -> Void)? { get set }
    func fetchCollections()
    func sortCollections(by type: CollectionListSortType)
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

    func sortCollections(by type: CollectionListSortType) {
        guard case .data(var collections) = state else { return }

        switch type {
        case .name:
            collections.sort { $0.name < $1.name }
        case .nftsCount:
            collections.sort { $0.nfts.count > $1.nfts.count }
        }

        state = .data(collections)
    }
}
