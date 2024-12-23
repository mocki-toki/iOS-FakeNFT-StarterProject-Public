import Foundation

typealias UsersCompletion = (Result<[Users], Error>) -> Void

protocol UserService {
    func fetchUsers(completion: @escaping UsersCompletion)
}

final class UserServiceImpl: UserService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchUsers(completion: @escaping UsersCompletion) {
        let request = UserRequest()
        networkClient.send(request: request, type: [Users].self, completionQueue: .main, onResponse: completion)
    }
}
