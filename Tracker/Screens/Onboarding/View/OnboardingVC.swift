import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let onboarding_01 = OnboardingViewControllerPage(backgroundImage: "onboardingPage1", pageText: "Отслеживайте только то, что хотите", buttonText: "Вот это технологии!")
    private let onboarding_02 = OnboardingViewControllerPage(backgroundImage: "onboardingPage2", pageText: "Даже если это не литры воды и йога", buttonText: "Вот это технологии!")
    
    private let pageControl = UIPageControl()
    private var orderedViewControllers: [UIViewController] = []
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        dataSource = self
        delegate = self
        
        orderedViewControllers = [onboarding_01, onboarding_02]
        
        onboarding_01.initialize(viewModel: OnboardingViewModel(for: OnboardingModel()))
        onboarding_02.initialize(viewModel: OnboardingViewModel(for: OnboardingModel()))
        
        if let firstVC = orderedViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        pageViewController(self, didUpdatePageCount: orderedViewControllers.count)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YPBlack")
        pageControl.pageIndicatorTintColor = UIColor(named: "YPBlack")?.withAlphaComponent(0.3)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -1*(50+60+24)),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let firstVC = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstVC) {
            self.pageViewController(self, didUpdatePageIndex: index)
        }
    }
    
    func pageViewController(_ pageViewController: OnboardingViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func pageViewController(_ pageViewController: OnboardingViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let prevIndex = viewControllerIndex - 1
        guard !(prevIndex < 0) else { return nil }
        
        return orderedViewControllers[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < orderedViewControllers.count else { return nil }
        
        return orderedViewControllers[nextIndex]
        
    }
}
