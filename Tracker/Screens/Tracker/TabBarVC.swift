import UIKit

final class TabBarViewController: UITabBarController {
    private let trackerListVC = UINavigationController(rootViewController: TrackerListViewController(store: DataStore()))
    private let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
    
    override func viewDidLoad() {
        trackerListVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "iconTrackers"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "iconStatistics"), tag: 1)
        viewControllers = [trackerListVC, statisticsVC]
    }
}
