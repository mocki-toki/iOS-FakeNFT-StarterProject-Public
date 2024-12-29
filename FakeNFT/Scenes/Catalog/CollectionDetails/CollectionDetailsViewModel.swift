import Foundation

enum CollectionDetailsState {
    case initial, loading
    case failed(Error)
    case data(NftCollection, URL)
}

enum CollectionDetailsNftListState {
    case initial, loading
    case failed(Error)
    case data([Nft])
}

protocol CollectionDetailsViewModel {
    var stateDidChanged: ((CollectionDetailsState) -> Void)? { get set }
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)? { get set }
    var nftStateDidChanged: (([UUID: NftState]) -> Void)? { get set }
    func fetchCollectionDetails()
    func toggleLikeNft(_ nft: Nft)
    func toggleCartNft(_ nft: Nft)
}

final class CollectionDetailsViewModelImpl: CollectionDetailsViewModel {
    private let input: CollectionDetailsInput
    private let nftCollectionService: NftCollectionService
    private let nftService: NftService
    private let nftStateStorage: NftStateStorage

    private var state = CollectionDetailsState.initial {
        didSet {
            stateDidChanged?(state)
        }
    }
    private var stateOfNfts: CollectionDetailsNftListState = .initial {
        didSet {
            stateOfNftsDidChanged?(stateOfNfts)
        }
    }

    private var nftStates: [UUID: NftState] = [:] {
        didSet {
            nftStateDidChanged?(nftStates)
        }
    }

    var stateDidChanged: ((CollectionDetailsState) -> Void)?
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)?
    var nftStateDidChanged: (([UUID: NftState]) -> Void)?

    init(
        input: CollectionDetailsInput,
        nftCollectionService: NftCollectionService,
        nftService: NftService,
        nftStateStorage: NftStateStorage
    ) {
        self.input = input
        self.nftCollectionService = nftCollectionService
        self.nftService = nftService
        self.nftStateStorage = nftStateStorage
    }

    func fetchCollectionDetails() {
        state = .loading
        nftCollectionService.loadCollectionById(id: input.id) { [weak self] result in
            switch result {
            case .success(let collectionDetails):
                // TODO: при мерже эпика "профиль" добавить получение URL автора из апи
                self?.state = .data(collectionDetails, URL(string: "https://ya.ru")!)
                self?.fetchNfts(for: collectionDetails.nfts)
                self?.updateNftStates()
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    private func fetchNfts(for nftIds: [UUID]) {
        stateOfNfts = .loading
        var nfts: [Nft] = []
        let group = DispatchGroup()
        var fetchError: Error?

        for nftId in nftIds {
            group.enter()
            Task {
                do {
                    let nft = try await fetchNft(id: nftId)
                    nfts.append(nft)
                } catch {
                    fetchError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = fetchError {
                self.stateOfNfts = .failed(error)
            } else {
                self.stateOfNfts = .data(nfts)
            }
        }
    }

    private func fetchNft(id nftId: UUID) async throws -> Nft {
        return try await withCheckedThrowingContinuation { continuation in
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nftDetails):
                    continuation.resume(returning: nftDetails)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func updateNftStates() {
        nftStates = nftStateStorage.getNftStates()
    }

    func toggleLikeNft(_ nft: Nft) {
        // TODO: интегрировать эпик профиля после мержа
        nftStateStorage.toggleLikeNft(nft)
        nftStates[nft.id] = nftStateStorage.getNftState(with: nft.id)
    }

    func toggleCartNft(_ nft: Nft) {
        // TODO: интегрировать эпик корзины после мержа
        nftStateStorage.toggleCartNft(nft)
        nftStates[nft.id] = nftStateStorage.getNftState(with: nft.id)
    }
}
