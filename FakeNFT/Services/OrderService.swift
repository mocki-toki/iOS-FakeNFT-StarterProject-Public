import Foundation

typealias OrderCompletion = (Result<Order, Error>) -> Void

protocol OrderService {
    func loadOrder(completion: @escaping (Result<[UUID], Error>) -> Void)
}

final class OrderServiceImpl: OrderService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadOrder(completion: @escaping (Result<[UUID], Error>) -> Void) {
        let request = OrderRequest()
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.nfts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

