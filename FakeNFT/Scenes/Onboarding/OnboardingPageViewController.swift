import UIKit
import SnapKit
import Then

final class OnboardingPageViewController: UIViewController {
    private let viewModel = OnboardingViewModel()
    private var pageViewController: UIPageViewController!
    private let customPageControl = UIView()
    private var slideIndicators: [UIView] = []
    
    private var currentPageIndex: Int = 0 {
        didSet {
            updatePageControl()
        }
    }
    
    var onboardingCompleted: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupPageControl()
    }
    
    // MARK: - Setup
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let initialViewModel = viewModel.getSlideViewModel(for: 0) {
            let initialVC = OnboardingContentViewController(viewModel: initialViewModel)
            setupActions(for: initialVC, index: 0)
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: true)
        }
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupPageControl() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-12)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
            make.height.equalTo(4)
        }
        
        for _ in 0..<viewModel.numberOfSlides() {
            let indicator = UIView().then {
                $0.backgroundColor = .yLightGrey
                $0.layer.cornerRadius = 2
            }
            slideIndicators.append(indicator)
            stackView.addArrangedSubview(indicator)
        }
        
        updatePageControl()
    }
    
    private func updatePageControl() {
        slideIndicators.enumerated().forEach { index, view in
            view.backgroundColor = index == currentPageIndex ? .yWhiteUniversal: .yBlackUniversal
        }
    }
    
    private func createSlideView(for index: Int) -> OnboardingContentViewController? {
        guard let slideViewModel = viewModel.getSlideViewModel(for: index) else { return nil }
        let slideVC = OnboardingContentViewController(viewModel: slideViewModel)
        setupActions(for: slideVC, index: index)
        return slideVC
    }
    
    private func goToNextPage() {
        let nextIndex = currentPageIndex + 1
        guard viewModel.canGoToNextSlide(from: currentPageIndex),
              let nextVC = createSlideView(for: nextIndex) else { return }
        
        currentPageIndex = nextIndex
        pageViewController.setViewControllers([nextVC], direction: .forward, animated: true)
    }
    
    private func setupActions(for slideVC: OnboardingContentViewController, index: Int) {
        slideVC.closeButtonAction = { [weak self] in
            self?.closeOnboarding()
        }
        slideVC.actionButtonAction = { [weak self] in
            if index == self?.viewModel.numberOfSlides() ?? 0 - 1 {
                self?.completeOnboarding()
            } else {
                self?.goToNextPage()
            }
        }
    }
    
    private func closeOnboarding() {
        onboardingCompleted?()
    }
    
    private func completeOnboarding() {
        onboardingCompleted?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard !viewModel.isFirstSlide(index: currentPageIndex) else { return nil }
            return createSlideView(for: currentPageIndex - 1)
        }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard !viewModel.isLastSlide(index: currentPageIndex) else { return nil }
            return createSlideView(for: currentPageIndex + 1)
        }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            guard completed,
                  let viewController = pageViewController.viewControllers?.first as? OnboardingContentViewController,
                  let index = viewModel.indexOfSlide(withTitle: viewController.titleLabel.text) else { return }
            currentPageIndex = index
        }
}
