import Foundation

class ProfileWebViewModel {
    private var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func loadUrl(completion: @escaping (URL?) -> Void) {
        var formattedUrlString = urlString
        
        if !formattedUrlString.lowercased().hasPrefix("https://") {
            formattedUrlString = "https://" + formattedUrlString
        }
        
        guard let url = URL(string: formattedUrlString) else {
            Logger.log("Ошибка: Неверный URL", level: .error)
            completion(nil)
            return
        }
        Logger.log("Переход по адресу \(url)", level: .debug)
        completion(url)
    }
}
