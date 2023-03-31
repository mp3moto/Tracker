import UIKit

class SplashViewController: UIViewController {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case firstLaunch
    }
    
    private(set) var firstLaunch: Bool {
        get {
            return !userDefaults.bool(forKey: Keys.firstLaunch.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.firstLaunch.rawValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("Can't access AppDelegate") }
        print(firstLaunch)
        if firstLaunch {
            firstLaunch = true
            appDelegate.changeVC(viewController: OnboardingViewController())
        } else {
            appDelegate.changeVC(viewController: TabBarViewController())
        }
    }
}
