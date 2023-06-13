import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        
        //Временное решение
        let dataStore = DataStore()
        let categoryStore = CategoryStore(dataStore: dataStore)
        let trackerStore = TrackerStore(dataStore: dataStore)
        let trackerRecordStore = TrackerRecordStore(dataStore: dataStore)
        //-----------------
        
        let trackerListVC = UINavigationController(rootViewController: TrackerListViewController(trackerStore: trackerStore, categoryStore: categoryStore, trackerRecordStore: trackerRecordStore))
        let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())

        trackerListVC.tabBarItem = UITabBarItem(title: LocalizedString.trackers, image: UIImage(named: "iconTrackers"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: LocalizedString.statistics, image: UIImage(named: "iconStatistics"), tag: 1)
        viewControllers = [trackerListVC, statisticsVC]
    }
}
