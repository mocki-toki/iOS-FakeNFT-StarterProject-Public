import Foundation

typealias CurrenciesCompletion = (Result<[Currencies], Error>) -> Void

protocol CurrenciesService {
    func fetchCurrencies(completion: @escaping CurrenciesCompletion)
}

final class CurrenciesServiceImpl: CurrenciesService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchCurrencies(completion: @escaping CurrenciesCompletion) {
        let request = CurrenciesRequest()
        networkClient.send(request: request, type: [Currencies].self) { result in
            completion(result)
        }
    }
}
