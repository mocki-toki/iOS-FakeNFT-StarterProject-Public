import Kingfisher
import UIKit

extension CollectionListViewController: ErrorView, LoadingView {
}

final class CollectionListViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: CollectionListViewModel
    private let detailsAssembly: CollectionDetailsAssembly

    private lazy var tableView = UITableView().then {
        $0.register(CollectionListTableCell.self)
        $0.dataSource = self
        $0.delegate = self
        $0.contentInset = .zero
        $0.separatorStyle = .none
    }

    private lazy var sortButton = UIBarButtonItem(
        image: UIImage.sort.withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(sortButtonTapped)
    ).then {
        $0.tintColor = .yBlack
    }

    lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Lifecycle

    init(viewModel: CollectionListViewModel, detailsAssembly: CollectionDetailsAssembly) {
        self.viewModel = viewModel
        self.detailsAssembly = detailsAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupBindings()

        viewModel.fetchCollections()
    }

    // MARK: - Private functions

    private func setupLayout() {
        [tableView, activityIndicator].forEach { item in
            view.addSubview(item)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.separatorStyle = .none

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        navigationItem.rightBarButtonItem = sortButton
    }

    private func setupBindings() {
        viewModel.stateDidChanged = { [weak self] state in
            self?.hideLoading()
            switch state {
            case .data(_):
                self?.tableView.reloadData()
            case .failed(let error):
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: String(localizable: .errorRepeat),
                    action: { self?.viewModel.fetchCollections() }
                )
                self?.showError(errorModel)
            case .loading, .initial:
                self?.showLoading()
            }
        }
    }

    // MARK: - Actions

    @objc private func sortButtonTapped() {
        let sortOptions = [
            CollectionListSortType.name: String(localizable: .sortNftName),
            CollectionListSortType.nftsCount: String(localizable: .sortNftCount),
        ]

        AlertPresenter.presentSortOptions(
            on: self,
            title: String(localizable: .sortAlert),
            cancelActionTitle: String(localizable: .sortClose),
            options: sortOptions.map { $1 },
            selectionHandler: { [weak self] optionText in
                guard let option = sortOptions.first(where: { $1 == optionText })?.key else {
                    return
                }
                self?.viewModel.sortCollections(by: option)
            }
        )
    }
}

// MARK: - UITableViewDataSource

extension CollectionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CollectionListTableCell = tableView.dequeueReusableCell()
        cell.selectionStyle = .none
        let cellModel = viewModel.cellModels[indexPath.row]
        cell.configure(with: cellModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CollectionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = viewModel.cellModels[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)

        let input = CollectionDetailsInput(id: cellModel.id)
        let collectionDetailsViewController = detailsAssembly.build(with: input)
        collectionDetailsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(collectionDetailsViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 187
    }
}
