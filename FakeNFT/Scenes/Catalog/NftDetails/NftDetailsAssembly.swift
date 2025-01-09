import UIKit

final class NftDetailsAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    public func build(with input: NftDetailsInput) -> NftDetailsViewController {
        let viewModel = NftDetailsViewModelImpl(
            input: input,
            nftCollectionService: servicesAssembly.nftCollectionService,
            nftService: servicesAssembly.nftService,
            orderService: servicesAssembly.orderService,
            orderPutService: servicesAssembly.orderPutService,
            profileService: servicesAssembly.profileService,
            profilePutService: servicesAssembly.profilePutService,
            currenciesService: servicesAssembly.currenciesService
        )
        
        let detailsAssembly = NftDetailsAssembly(servicesAssembly: servicesAssembly)
        
        let viewController = NftDetailsViewController(viewModel: viewModel, detailsAssembly: detailsAssembly)
        return viewController
    }
}
