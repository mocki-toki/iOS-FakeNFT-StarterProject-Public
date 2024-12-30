import Foundation

typealias OrderPutCompletion = (Result<Order, Error>) -> Void

protocol OrderPutService {
    func sendOrderPutRequest(
        nftIds: [UUID],
        completion: @escaping OrderPutCompletion
    )
}

final class OrderPutServiceImpl: OrderPutService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func sendOrderPutRequest(
        nftIds: [UUID],
        completion: @escaping OrderPutCompletion
    ) {
        let dto = OrderDto(nftIds: nftIds)
        let request = OrderPutRequest(dto: dto)
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let order):
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
