import UIKit
import WebKit

final class WebViewController: UIViewController {
    private let url: URL
    private let webView = WKWebView()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebsite()
    }
    
    private func setupUI() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadWebsite() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
