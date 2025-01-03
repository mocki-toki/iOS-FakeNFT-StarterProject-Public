import Foundation

typealias CurrenciesCompletion = (Result<[Currencies], Error>) -> Void
typealias SetCurrenciesCompletion = (Result<SetCurrency, Error>) -> Void

protocol CurrenciesService {
    func fetchCurrencies(completion: @escaping CurrenciesCompletion)
    func setCurrencyForTheOrder(id: String, completion: @escaping SetCurrenciesCompletion)
}

final class CurrenciesServiceImpl: CurrenciesService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    private func handleResult<T>(_ result: Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let data):
            Logger.log("Success: \(data)")
            completion(.success(data))
        case .failure(let error):
            Logger.log("Failure: \(error.localizedDescription)", level: .error)
            completion(.failure(error))
        }
    }
    
    func fetchCurrencies(completion: @escaping CurrenciesCompletion) {
        let request = CurrenciesRequest()
        networkClient.send(request: request, type: [Currencies].self) { result in
            self.handleResult(result, completion: completion)
        }
    }
    
    func setCurrencyForTheOrder(id: String, completion: @escaping SetCurrenciesCompletion) {
        let request = SetCurrencyRequest(id: id)
        networkClient.send(request: request, type: SetCurrency.self) { result in
            self.handleResult(result, completion: completion)
        }
    }
}
