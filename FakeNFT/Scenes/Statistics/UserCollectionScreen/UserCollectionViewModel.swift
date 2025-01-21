import Foundation

final class UserCollectionViewModel {
    private let nftService: NftService
    private let orderService: OrderService
    private let orderPutService: OrderPutService
    private let profileService: ProfileService
    private let profilePutService: ProfilePutService
    
    private var userId: String
    private var nfts: [Nft] = []
    private var additions: [UUID: CollectionDetailsTableCellAdditionalModel] = [:]
    
    var onDataUpdated: (() -> Void)?
    var onErrorOccurred: ((String, @escaping () -> Void) -> Void)?
    
    init(userId: String, nftService: NftService,
         orderService: OrderService,
         orderPutService: OrderPutService,
         profileService: ProfileService,
         profilePutService: ProfilePutService) {
        self.userId = userId
        self.nftService = nftService
        self.orderService = orderService
        self.orderPutService = orderPutService
        self.profileService = profileService
        self.profilePutService = profilePutService
    }
    
    func loadUserNfts() {
        Logger.log("Started loading NFTs for userId: \(userId)", level: .info)
        
        nftService.loadUserDetails(userId: userId) { [weak self] (result: Result<Users, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    Logger.log("Successfully loaded user details with \(user.nfts.count) NFTs", level: .info)
                    let nftIds = user.nfts.map { $0.uuidString }
                    self?.loadNftsByIds(nftIds)
                    self?.fetchNftAdditionals()
                case .failure(let error):
                    Logger.log("Error loading user details: \(error.localizedDescription)", level: .error)
                    self?.onErrorOccurred?("Error loading user details: \(error.localizedDescription)", {
                        self?.loadUserNfts()
                    })
                }
            }
        }
    }
    
    func loadNftsByIds(_ nftIds: [String]) {
        Logger.log("Started loading NFTs by IDs: \(nftIds)", level: .info)
        let group = DispatchGroup()
        var loadedNfts: [Nft] = []
        var errors: [Error] = []
        
        nftIds.forEach { nftId in
            guard let uuid = UUID(uuidString: nftId) else {
                Logger.log("Invalid UUID string: \(nftId)", level: .error)
                errors.append(NSError(domain: "Invalid UUID",
                                      code: 0,
                                      userInfo: [NSLocalizedDescriptionKey: "Invalid UUID: \(nftId)"]))
                return
            }
            
            group.enter()
            nftService.loadNft(id: uuid) { result in
                switch result {
                case .success(let nft):
                    Logger.log("Successfully loaded NFT with id: \(nft.id)", level: .info)
                    loadedNfts.append(nft)
                case .failure(let error):
                    Logger.log("Error loading NFT with id \(nftId): \(error.localizedDescription)", level: .error)
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                Logger.log("Successfully loaded all NFTs", level: .info)
                self.nfts = loadedNfts
                self.onDataUpdated?()
            } else {
                Logger.log("Failed to load some NFTs", level: .warning)
                self.onErrorOccurred?("Failed to load some NFTs.", {
                    self.loadNftsByIds(nftIds)
                })
            }
        }
    }
    
    func getNfts() -> [Nft] {
        return nfts
    }
    
    func getAdditions() -> [UUID: CollectionDetailsTableCellAdditionalModel] {
        return additions
    }
    
    private func fetchNftAdditionals() {
        var nftsInCart: [UUID] = []
        var nftsLiked: [UUID] = []

        orderService.loadOrder { result in
            switch result {
            case .success(let nfts):
                nftsInCart = nfts.map { $0 }

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

                        self.additions = changes
                        self.onDataUpdated?()
                    case .failure(let error):
                        self.onErrorOccurred?("Loading failure: \(error)", {
                            self.fetchNftAdditionals()
                        })
                    }
                }
            case .failure(let error):
                self.onErrorOccurred?("Loading failure: \(error)", {
                    self.fetchNftAdditionals()
                })
                return
            }
        }
    }

    func toggleLikeNft(byId id: UUID) {
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

                            if let value = self.additions[id] {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: isLiked, isInCart: value.isInCart)
                            } else if isLiked {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: true, isInCart: false)
                            }

                            self.onDataUpdated?()
                        case .failure(let error):
                            self.onErrorOccurred?("Toggle like failure: \(error)", {
                                self.toggleLikeNft(byId: id)
                            })
                        }
                    }
                } else {
                    self.profilePutService.sendProfilePutRequest(
                        profile: ProfileDto(likes: profile.likes + [id], avatar: nil, name: nil)
                    ) { result in
                        switch result {
                        case .success(let profile):
                            let isLiked = profile.likes.contains(id)

                            if let value = self.additions[id] {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: isLiked, isInCart: value.isInCart)
                            } else if isLiked {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: true, isInCart: false)
                            }

                            self.onDataUpdated?()
                        case .failure(let error):
                            self.onErrorOccurred?("Toggle like failure: \(error)", {
                                self.toggleLikeNft(byId: id)
                            })
                        }
                    }
                }
            case .failure(let error):
                self.onErrorOccurred?("Toggle like failure: \(error)", {
                    self.toggleLikeNft(byId: id)
                })
            }
        }
    }

    func toggleCartNft(byId id: UUID) {
        orderService.loadOrder { result in
            switch result {
            case .success(let nfts):
                if nfts.contains(id) {
                    self.orderPutService.sendOrderPutRequest(nftIds: nfts.filter { $0 != id })
                    {
                        result in
                        switch result {
                        case .success(let order):
                            let isInCart = order.nfts.contains(id)

                            if let value = self.additions[id] {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: value.isLiked, isInCart: isInCart)
                            } else if isInCart {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: false, isInCart: true)
                            }

                            self.onDataUpdated?()
                        case .failure(let error):
                            self.onErrorOccurred?("Adding cart failure: \(error)", {
                                self.toggleCartNft(byId: id)
                            })
                        }
                    }
                } else {
                    self.orderPutService.sendOrderPutRequest(nftIds: nfts + [id]) { result in
                        switch result {
                        case .success(let order):
                            let isInCart = order.nfts.contains(id)

                            if let value = self.additions[id] {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: value.isLiked, isInCart: isInCart)
                            } else if isInCart {
                                self.additions[id] = CollectionDetailsTableCellAdditionalModel(
                                    isLiked: false, isInCart: true)
                            }

                            self.onDataUpdated?()
                        case .failure(let error):
                            self.onErrorOccurred?("Adding cart failure: \(error)", {
                                self.toggleCartNft(byId: id)
                            })
                        }
                    }
                }
            case .failure(let error):
                self.onErrorOccurred?("Adding cart failure: \(error)", {
                    self.toggleCartNft(byId: id)
                })
            }
        }
    }
}
