import Foundation

protocol ProfileNetworkServiceProtocol {
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    func updateProfile(profileData: String, completion: @escaping (Result<Profile, Error>) -> Void)
}
