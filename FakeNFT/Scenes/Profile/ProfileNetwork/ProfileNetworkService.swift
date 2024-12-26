import Foundation

final class ProfileNetworkService: ProfileNetworkServiceProtocol {
    // MARK: - Private Properties
    private let networkClient: NetworkClient
    
    // MARK: - Initializers
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Properties
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let request = ProfileRequest()
        networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }
    
    func updateProfile(profileData: UpdateProfileDto,
                       completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let request = UpdateProfileRequest(dto: profileData)
        networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }
}
