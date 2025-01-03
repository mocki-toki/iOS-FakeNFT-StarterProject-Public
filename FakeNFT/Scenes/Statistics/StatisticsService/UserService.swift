import Foundation

typealias UsersCompletion = (Result<[Users], Error>) -> Void
typealias UserDetailsCompletion = (Result<Users, Error>) -> Void

protocol UserService {
    func fetchUsers(completion: @escaping UsersCompletion)
    func fetchUserDetails(userId: String, completion: @escaping UserDetailsCompletion)
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
    
    func fetchUserDetails(userId: String, completion: @escaping UserDetailsCompletion) {
        let request = UserRequest(userId: userId)
        networkClient.send(request: request, type: Users.self, completionQueue: .main, onResponse: completion)
    }
}
