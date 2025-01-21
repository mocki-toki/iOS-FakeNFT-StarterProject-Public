import Foundation

typealias ProfilePutCompletion = (Result<Profile, Error>) -> Void

protocol ProfilePutService {
    func sendProfilePutRequest(
        profile: ProfileDto,
        completion: @escaping ProfilePutCompletion
    )
}

final class ProfilePutServiceImpl: ProfilePutService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func sendProfilePutRequest(
        profile: ProfileDto,
        completion: @escaping ProfilePutCompletion
    ) {
        let request = ProfilePutRequest(dto: profile)
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let profile):
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
