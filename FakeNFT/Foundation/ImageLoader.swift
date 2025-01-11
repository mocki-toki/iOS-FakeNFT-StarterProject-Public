import UIKit
import Kingfisher

final class ImageLoader {
    static func loadImage(from url: URL?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                completion(.success(imageResult.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
