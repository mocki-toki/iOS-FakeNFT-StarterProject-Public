final class ServicesAssembly {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let nftCollectionStorage: NftCollectionStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        nftCollectionStorage: NftCollectionStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.nftCollectionStorage = nftCollectionStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    var currenciesService: CurrenciesService {
        CurrenciesServiceImpl(networkClient: networkClient)
    }
    
    lazy var profileNetworkService: ProfileNetworkService = {
        ProfileNetworkService(networkClient: networkClient)
    }()
    
    var userService: UserService {
        UserServiceImpl(networkClient: networkClient)
    }
    
    var profileService: ProfileService {
        ProfileServiceImpl(
            networkClient: networkClient
        )
    }
    
    var profilePutService: ProfilePutService {
        ProfilePutServiceImpl(
            networkClient: networkClient
        )
    }
    
    var orderService: OrderService {
        OrderServiceImpl(networkClient: networkClient)
    }
    
    var orderPutService: OrderPutService {
        OrderPutServiceImpl(networkClient: networkClient)
    }

    var nftCollectionService: NftCollectionService {
        NftCollectionServiceImpl(
            networkClient: networkClient,
            storage: nftCollectionStorage)
    }
}

