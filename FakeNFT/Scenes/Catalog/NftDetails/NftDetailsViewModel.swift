import Foundation

enum NftDetailsState {
    case initial, loading
    case failed(Error)
    case data(NftDetailsModel)
}

protocol NftDetailsViewModel {
    var stateDidChanged: ((NftDetailsState) -> Void)? { get set }
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)? { get set }
    var stateOfNftAdditionalsDidChanged: ((CollectionDetailsNftListAdditionalState) -> Void)? {
        get set
    }

    var detailsModel: NftDetailsModel? { get }
    var cellModels: [CollectionDetailsTableCellModel] { get }
    var cellAdditionalModels: [UUID: CollectionDetailsTableCellAdditionalModel] { get }

    func fetchNftDetails()
    func toggleLikeNft(byId id: UUID)
    func toggleCartNft(byId id: UUID)
}

final class NftDetailsViewModelImpl: NftDetailsViewModel {
    private let input: NftDetailsInput
    private let nftCollectionService: NftCollectionService
    private let nftService: NftService
    
    private let orderService: OrderService
    private let orderPutService: OrderPutService

    private let profileService: ProfileService
    private let profilePutService: ProfilePutService
    
    private let currenciesService: CurrenciesService
    
    private var state = NftDetailsState.initial {
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
    
    var stateDidChanged: ((NftDetailsState) -> Void)?
    var stateOfNftsDidChanged: ((CollectionDetailsNftListState) -> Void)?
    var stateOfNftAdditionalsDidChanged: ((CollectionDetailsNftListAdditionalState) -> Void)?
    
    var detailsModel: NftDetailsModel? {
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
        input: NftDetailsInput,
        nftCollectionService: NftCollectionService,
        nftService: NftService,
        orderService: OrderService,
        orderPutService: OrderPutService,
        profileService: ProfileService,
        profilePutService: ProfilePutService,
        currenciesService: CurrenciesService
    ) {
        self.input = input
        self.nftCollectionService = nftCollectionService
        self.nftService = nftService
        self.orderService = orderService
        self.orderPutService = orderPutService
        self.profileService = profileService
        self.profilePutService = profilePutService
        self.currenciesService = currenciesService
    }
    
    func fetchNftDetails() {
        state = .loading
        nftService.loadNft(id: input.nftId) { [weak self] result in
            switch result {
            case .success(let nftModel):
                guard let self = self else { return }
                nftCollectionService.loadCollectionById(id: self.input.collectionId) { [weak self] result in
                    switch result {
                    case .success(let collectionModel):
                        guard let self = self else { return }
                        currenciesService.fetchCurrencies { [weak self] result in
                            switch result {
                            case .success(let currencies):
                                self?.state = .data(
                                    NftDetailsModel(
                                        id: nftModel.id,
                                        images: nftModel.images,
                                        name: nftModel.name,
                                        rating: nftModel.rating,
                                        collectionName: collectionModel.name,
                                        price: nftModel.price,
                                        authorSiteUrl: nftModel.author,
                                        currencies: currencies.map {
                                            NftDetailsCurrencyModel(
                                                id: $0.id,
                                                imageUrl: $0.image,
                                                name: $0.name,
                                                title: $0.title)
                                        }
                                    )
                                )
                                
                                self?.fetchNfts(for: collectionModel.nfts)
                                self?.fetchNftAdditionals()
                            case .failure(let error):
                                self?.state = .failed(error)
                            }
                        }
                    case .failure(let error):
                        self?.state = .failed(error)
                    }
                }
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
                                collectionId: self.input.collectionId,
                                coverUrl: $0.images.first ?? URL(string: "")!,
                                rating: $0.rating,
                                name: $0.name,
                                price: $0.price
                            )
                        }
                    )
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
