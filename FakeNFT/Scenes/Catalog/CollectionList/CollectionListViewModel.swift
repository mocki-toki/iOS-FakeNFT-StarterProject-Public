import Foundation

enum CollectionListState {
    case initial, loading
    case failed(Error)
    case data([CollectionListTableCellModel])
}

enum CollectionListSortType {
    case name
    case nftsCount
}

protocol CollectionListViewModel {
    var stateDidChanged: ((CollectionListState) -> Void)? { get set }
    var cellModels: [CollectionListTableCellModel] { get }
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

    var cellModels: [CollectionListTableCellModel] {
        if case .data(let collections) = state {
            return collections
        } else {
            return []
        }
    }

    init(nftCollectionService: NftCollectionService) {
        self.nftCollectionService = nftCollectionService
    }

    func fetchCollections() {
        state = .loading
        nftCollectionService.loadCollections { [weak self] result in
            switch result {
            case .success(let collections):
                self?.state = .data(
                    collections.map {
                        CollectionListTableCellModel(
                            id: $0.id, coverUrl: $0.cover, name: $0.name, count: $0.nfts.count)
                    })
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
            collections.sort { $0.count > $1.count }
        }

        state = .data(collections)
    }
}
