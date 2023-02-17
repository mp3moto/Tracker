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
        print("didFinishAnimating called")
        
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

class OnboardingViewControllerPage: UIViewController {
    
    var backgroundImage: String
    var pageText: String
    var buttonText: String
    
    init(backgroundImage: String, pageText: String, buttonText: String) {
        self.backgroundImage = backgroundImage
        self.pageText = pageText
        self.buttonText = buttonText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc private func showHomeScreen() {
        let homeVC = TabBarViewController()
        homeVC.modalPresentationStyle = .fullScreen
        homeVC.modalTransitionStyle = .coverVertical
        present(homeVC, animated: true)
    }
    
    func setup() {
        let bgImage = UIImageView(image: UIImage(named: backgroundImage))
        let label = UILabel()
        let button = YPButton(text: "Вот это технологии!", destructive: false)
        
        button.addTarget(self, action: #selector(showHomeScreen), for: .touchUpInside)
        
        label.text = pageText
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        label.textColor = UIColor(named: "YPBlack")
        label.numberOfLines = 2
        label.textAlignment = .center
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(bgImage)
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            bgImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImage.topAnchor.constraint(equalTo: view.topAnchor),
            bgImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 76),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 26),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
}
