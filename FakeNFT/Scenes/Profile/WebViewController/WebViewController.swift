import UIKit
import WebKit
import SnapKit
import Then

class WebViewController: UIViewController, WKNavigationDelegate {
    // MARK: - Properties
    private var viewModel: WebViewModel
    private weak var webView: WKWebView!
    
    // MARK: - UI Components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .gray
    }
    
    // MARK: - Initialization
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yWhite
        
        setupViews()
        setupConstraints()
        
        loadPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        webView = WKWebView().then {
            $0.navigationDelegate = self
        }
        self.navigationController?.navigationBar.tintColor = .black
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func loadPage() {
        viewModel.loadUrl { [weak self] url in
            guard let self = self, let url = url else {
                Logger.log("Ошибка: Невозможно загрузить URL")
                return
            }
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    private func showAlert(for error: Error) {
        AlertPresenter.presentAlert(
            on: self,
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            buttons: [
                AlertPresenter.Button(
                    title: "Отмена",
                    action: { [weak self] in self?.dismissWebView() },
                    style: .cancel,
                    isPreferred: false
                )
            ]
        )
    }
    
    private func dismissWebView() {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - WKNavigationDelegate Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let urlError = error as? URLError, urlError.code == .cannotFindHost {
            activityIndicator.stopAnimating()
            showAlert(for: urlError)
            Logger.log("Error \(urlError.localizedDescription)", level: .error)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let urlError = error as? URLError, urlError.code == .cannotFindHost {
            activityIndicator.stopAnimating()
            showAlert(for: urlError)
            Logger.log("Error \(urlError.localizedDescription)", level: .error)
        }
    }
}
