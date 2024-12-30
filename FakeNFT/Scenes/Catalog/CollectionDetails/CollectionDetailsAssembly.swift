import UIKit

final class CollectionDetailsAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    public func build(with input: CollectionDetailsInput) -> CollectionDetailsViewController {
        let viewModel = CollectionDetailsViewModelImpl(
            input: input,
            nftCollectionService: servicesAssembly.nftCollectionService,
            nftService: servicesAssembly.nftService,
            orderService: servicesAssembly.orderService,
            orderPutService: servicesAssembly.orderPutService,
            profileService: servicesAssembly.profileService,
            profilePutService: servicesAssembly.profilePutService
        )
        let viewController = CollectionDetailsViewController(viewModel: viewModel)
        return viewController
    }
}
