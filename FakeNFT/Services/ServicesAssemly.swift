final class ServicesAssembly {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let nftCollectionStorage: NftCollectionStorage
    public let nftStateStorage: NftStateStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        nftCollectionStorage: NftCollectionStorage,
        nftStateStorage: NftStateStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.nftCollectionStorage = nftCollectionStorage
        self.nftStateStorage = nftStateStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var nftCollectionService: NftCollectionService {
        NftCollectionServiceImpl(
            networkClient: networkClient,
            storage: nftCollectionStorage
        )
    }
}
