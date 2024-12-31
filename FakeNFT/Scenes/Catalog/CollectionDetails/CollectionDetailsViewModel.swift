import Foundation

enum CollectionDetailsState {
    case initial, loading
    case failed(Error)
    case data(CollectionDetailsModel)
}

enum CollectionDetailsNftListState {
    case initial, loading
    case failed(Error)
    case data([CollectionDetailsTableCellModel])
}

enum CollectionDetailsNftListAdditionalState {
    case initial, loading
    case failed(Error)
    case data([UUID: CollectionDetailsTableCellAdditionalModel])
}

protocol CollectionDetailsViewModel {
    var stateDidChanged: ((CollectionDetailsState) -> Void)? { get set }
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)? { get set }
    var stateOfNftAdditionalsDidChanged: ((CollectionDetailsNftListAdditionalState) -> Void)? {
        get set
    }

    var detailsModel: CollectionDetailsModel? { get }
    var cellModels: [CollectionDetailsTableCellModel] { get }
    var cellAdditionalModels: [UUID: CollectionDetailsTableCellAdditionalModel] { get }

    func fetchCollectionDetails()
    func toggleLikeNft(byId id: UUID)
    func toggleCartNft(byId id: UUID)
}

final class CollectionDetailsViewModelImpl: CollectionDetailsViewModel {
    private let input: CollectionDetailsInput
    private let nftCollectionService: NftCollectionService
    private let nftService: NftService

    private let orderService: OrderService
    private let orderPutService: OrderPutService

    private let profileService: ProfileService
    private let profilePutService: ProfilePutService

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

    private var stateOfNftAdditionals: CollectionDetailsNftListAdditionalState = .initial {
        didSet {
            stateOfNftAdditionalsDidChanged?(stateOfNftAdditionals)
        }
    }

    var stateDidChanged: ((CollectionDetailsState) -> Void)?
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)?
    var stateOfNftAdditionalsDidChanged: ((CollectionDetailsNftListAdditionalState) -> Void)?

    var detailsModel: CollectionDetailsModel? {
        if case .data(let model) = state {
            return model
        } else {
            return nil
        }
    }

    var cellModels: [CollectionDetailsTableCellModel] {
        if case .data(let models) = stateOfNfts {
            return models
        } else {
            return []
        }
    }

    var cellAdditionalModels: [UUID: CollectionDetailsTableCellAdditionalModel] {
        if case .data(let models) = stateOfNftAdditionals {
            return models
        } else {
            return [:]
        }
    }

    init(
        input: CollectionDetailsInput,
        nftCollectionService: NftCollectionService,
        nftService: NftService,
        orderService: OrderService,
        orderPutService: OrderPutService,
        profileService: ProfileService,
        profilePutService: ProfilePutService
    ) {
        self.input = input
        self.nftCollectionService = nftCollectionService
        self.nftService = nftService
        self.orderService = orderService
        self.orderPutService = orderPutService
        self.profileService = profileService
        self.profilePutService = profilePutService
    }

    func fetchCollectionDetails() {
        state = .loading
        nftCollectionService.loadCollectionById(id: input.id) { [weak self] result in
            switch result {
            case .success(let collectionDetails):
                self?.state = .data(
                    CollectionDetailsModel(
                        id: collectionDetails.id,
                        coverUrl: collectionDetails.cover,
                        name: collectionDetails.name,
                        author: collectionDetails.author,
                        authorSiteUrl: nil,
                        description: collectionDetails.description))
                self?.fetchNfts(for: collectionDetails.nfts)
                self?.fetchNftAdditionals()
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

        group.notify(
            queue: .main,
            execute: {
                if let error = fetchError {
                    self.stateOfNfts = .failed(error)
                } else {
                    self.stateOfNfts = .data(
                        nfts.map {
                            CollectionDetailsTableCellModel(
                                id: $0.id,
                                coverUrl: $0.images.first ?? URL(string: "")!,
                                rating: $0.rating,
                                name: $0.name,
                                price: $0.price
                            )
                        }
                    )

                    if let authorSiteUrl = nfts.first?.author, let detailsModel = self.detailsModel {
                        self.state = .data(
                            CollectionDetailsModel(
                                id: detailsModel.id,
                                coverUrl: detailsModel.coverUrl,
                                name: detailsModel.name,
                                author: detailsModel.author,
                                authorSiteUrl: authorSiteUrl,
                                description: detailsModel.description
                            )
                        )
                    }
                }
            })
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

    private func fetchNftAdditionals() {
        var nftsInCart: [UUID] = []
        var nftsLiked: [UUID] = []

        stateOfNftAdditionals = .loading

        orderService.loadOrder { result in
            switch result {
            case .success(let order):
                nftsInCart = order.nfts.map { $0 }

                self.profileService.loadProfile { result in
                    switch result {
                    case .success(let profile):
                        nftsLiked = profile.likes.map { $0 }

                        var changes: [UUID: CollectionDetailsTableCellAdditionalModel] = [:]
                        for nftId in nftsInCart {
                            changes[nftId] = CollectionDetailsTableCellAdditionalModel(
                                isLiked: nftsLiked.contains(nftId),
                                isInCart: nftsInCart.contains(nftId))
                        }
                        for nftId in nftsLiked {
                            changes[nftId] = CollectionDetailsTableCellAdditionalModel(
                                isLiked: nftsLiked.contains(nftId),
                                isInCart: nftsInCart.contains(nftId))
                        }

                        self.stateOfNftAdditionals = .data(changes)
                    case .failure(let error):
                        self.stateOfNftAdditionals = .failed(error)
                    }
                }
            case .failure(let error):
                self.stateOfNftAdditionals = .failed(error)
                return
            }
        }
    }

    func toggleLikeNft(byId id: UUID) {
        var additions = cellAdditionalModels

        stateOfNftAdditionals = .loading
        profileService.loadProfile { result in
            switch result {
            case .success(let profile):
                if profile.likes.contains(id) {
                    self.profilePutService.sendProfilePutRequest(
                        profile: ProfileDto(
                            likes: profile.likes.filter { $0 != id }, avatar: nil, name: nil)
                    ) { result in
                        switch result {
                        case .success(let profile):
                            let isLiked = profile.likes.contains(id)

                            if let value = additions[id] {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: isLiked, isInCart: value.isInCart)
                            } else if isLiked {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: true, isInCart: false)
                            }

                            self.stateOfNftAdditionals = .data(additions)
                        case .failure(let error):
                            self.stateOfNftAdditionals = .failed(error)
                        }
                    }
                } else {
                    self.profilePutService.sendProfilePutRequest(
                        profile: ProfileDto(likes: profile.likes + [id], avatar: nil, name: nil)
                    ) { result in
                        switch result {
                        case .success(let profile):
                            let isLiked = profile.likes.contains(id)

                            if let value = additions[id] {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: isLiked, isInCart: value.isInCart)
                            } else if isLiked {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: true, isInCart: false)
                            }

                            self.stateOfNftAdditionals = .data(additions)
                        case .failure(let error):
                            self.stateOfNftAdditionals = .failed(error)
                        }
                    }
                }
            case .failure(let error):
                self.stateOfNftAdditionals = .failed(error)
            }
        }
    }

    func toggleCartNft(byId id: UUID) {
        var additions = cellAdditionalModels

        stateOfNftAdditionals = .loading
        orderService.loadOrder { result in
            switch result {
            case .success(let order):
                if order.nfts.contains(id) {
                    self.orderPutService.sendOrderPutRequest(nftIds: order.nfts.filter { $0 != id })
                    {
                        result in
                        switch result {
                        case .success(let order):
                            let isInCart = order.nfts.contains(id)

                            if let value = additions[id] {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: value.isLiked, isInCart: isInCart)
                            } else if isInCart {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: false, isInCart: true)
                            }

                            self.stateOfNftAdditionals = .data(additions)
                        case .failure(let error):
                            self.stateOfNftAdditionals = .failed(error)
                        }
                    }
                } else {
                    self.orderPutService.sendOrderPutRequest(nftIds: order.nfts + [id]) { result in
                        switch result {
                        case .success(let order):
                            let isInCart = order.nfts.contains(id)

                            if let value = additions[id] {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: value.isLiked, isInCart: isInCart)
                            } else if isInCart {
                                additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: false, isInCart: true)
                            }

                            self.stateOfNftAdditionals = .data(additions)
                        case .failure(let error):
                            self.stateOfNftAdditionals = .failed(error)
                        }
                    }
                }
            case .failure(let error):
                self.stateOfNftAdditionals = .failed(error)
            }
        }
    }
}
