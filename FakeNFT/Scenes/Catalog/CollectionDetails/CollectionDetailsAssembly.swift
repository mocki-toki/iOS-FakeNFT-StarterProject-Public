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
            nftStateStorage: servicesAssembly.nftStateStorage
        )
        let viewController = CollectionDetailsViewController(viewModel: viewModel)
        return viewController
    }
}
