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
            switch result {
            case .success(let currencies):
                Logger.log("Currencies fetched successfully: \(currencies)")
                completion(.success(currencies))
            case .failure(let error):
                Logger.log("Failed to fetch currencies: \(error)", level: .error)
                completion(.failure(error))
            }
        }
    }
}
