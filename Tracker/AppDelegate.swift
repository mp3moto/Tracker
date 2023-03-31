import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    func changeVC(viewController: UIViewController) {
        window?.rootViewController = viewController
    }
}

