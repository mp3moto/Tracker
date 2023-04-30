import UIKit

final class TabBarViewController: UITabBarController {
    private let trackerListVC = UINavigationController(rootViewController: TrackerListViewController(store: DataStore()))
    private let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
    
    override func viewDidLoad() {
        trackerListVC.tabBarItem = UITabBarItem(title: LocalizedString.trackers, image: UIImage(named: "iconTrackers"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: LocalizedString.statistics, image: UIImage(named: "iconStatistics"), tag: 1)
        viewControllers = [trackerListVC, statisticsVC]
    }
}
