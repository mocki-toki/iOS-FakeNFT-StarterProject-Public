import UIKit

final class CollectionListAssembly {
    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    public func build() -> CollectionListViewController {
        let detailsAssembly = CollectionDetailsAssembly(servicesAssembly: servicesAssembler)

        let viewModel = CollectionListViewModelImpl(nftCollectionService: servicesAssembler.nftCollectionService)
        let viewController = CollectionListViewController(viewModel: viewModel, detailsAssembly: detailsAssembly)
        return viewController
    }
}
