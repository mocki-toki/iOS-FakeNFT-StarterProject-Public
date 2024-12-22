import Foundation

class WebViewModel {
    private var urlString: String
    
    // Инициализация с URL-строкой
    init(urlString: String) {
        self.urlString = urlString
    }
    
    // Метод для получения корректного URL
    func loadUrl(completion: @escaping (URL?) -> Void) {
        var formattedUrlString = urlString
        
        // Проверка, начинается ли строка с "https://"
        if !formattedUrlString.lowercased().hasPrefix("https://") {
            formattedUrlString = "https://" + formattedUrlString
        }
        
        // Преобразование строки в URL
        guard let url = URL(string: formattedUrlString) else {
            print("Ошибка: Неверный URL")
            completion(nil)
            return
        }
        print(url)
        completion(url)
    }
}
