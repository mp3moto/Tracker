import UIKit

final class TrackerListViewController: UIViewController, DataStoreDelegate {
    private var store: DataStore
    private var trackerData: TrackerStore?
    private var categoryData: CategoryStore?
    private var trackerRecordData: TrackerRecordStore?
    private let dateFormatter = DateFormatter()
    private let searchController = UISearchController(searchResultsController: nil)
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var categories: [TrackerCategory]?
    private var visibleCategories: [TrackerCategory]?
    private var completedTrackers: [TrackerRecord]?
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text,
              text.count > 0
        else { return true }
        return false
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private let datePicker = UIDatePicker()
    private var dateFromDatePicker: Date?
    
    private let noTrackersView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "no trackers"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = "Что будем отслеживать?"
        noTrackersIndicatorLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        
        noTrackersIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noTrackersIndicatorView.addSubview(noTrackersIndicatorImage)
        noTrackersIndicatorView.addSubview(noTrackersIndicatorLabel)
        
        let noTrackersIndicatorImageWidth = 80.0
        let noTrackersIndicatorImageHeight = 80.0
        let spaceBetweenImageAndLabel = 8.0
        let noTrackersIndicatorLabelHeight = noTrackersIndicatorLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let totalHeight = noTrackersIndicatorImageHeight + spaceBetweenImageAndLabel + noTrackersIndicatorLabelHeight
        
        NSLayoutConstraint.activate([
            noTrackersIndicatorImage.centerXAnchor.constraint(equalTo: noTrackersIndicatorView.centerXAnchor),
            noTrackersIndicatorImage.topAnchor.constraint(equalTo: noTrackersIndicatorView.topAnchor),
            noTrackersIndicatorImage.heightAnchor.constraint(equalToConstant: noTrackersIndicatorImageHeight),
            noTrackersIndicatorImage.widthAnchor.constraint(equalToConstant: noTrackersIndicatorImageWidth),
            noTrackersIndicatorLabel.topAnchor.constraint(equalTo: noTrackersIndicatorImage.bottomAnchor, constant: spaceBetweenImageAndLabel),
            noTrackersIndicatorLabel.centerXAnchor.constraint(equalTo: noTrackersIndicatorImage.centerXAnchor),
            noTrackersIndicatorView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        return noTrackersIndicatorView
    }()
    
    private let noTrackersFoundView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "no trackers found"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = "Ничего не найдено"
        noTrackersIndicatorLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        
        noTrackersIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noTrackersIndicatorView.addSubview(noTrackersIndicatorImage)
        noTrackersIndicatorView.addSubview(noTrackersIndicatorLabel)
        
        let noTrackersIndicatorImageWidth = 80.0
        let noTrackersIndicatorImageHeight = 80.0
        let spaceBetweenImageAndLabel = 8.0
        let noTrackersIndicatorLabelHeight = noTrackersIndicatorLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let totalHeight = noTrackersIndicatorImageHeight + spaceBetweenImageAndLabel + noTrackersIndicatorLabelHeight
        
        NSLayoutConstraint.activate([
            noTrackersIndicatorImage.centerXAnchor.constraint(equalTo: noTrackersIndicatorView.centerXAnchor),
            noTrackersIndicatorImage.topAnchor.constraint(equalTo: noTrackersIndicatorView.topAnchor),
            noTrackersIndicatorImage.heightAnchor.constraint(equalToConstant: noTrackersIndicatorImageHeight),
            noTrackersIndicatorImage.widthAnchor.constraint(equalToConstant: noTrackersIndicatorImageWidth),
            noTrackersIndicatorLabel.topAnchor.constraint(equalTo: noTrackersIndicatorImage.bottomAnchor, constant: spaceBetweenImageAndLabel),
            noTrackersIndicatorLabel.centerXAnchor.constraint(equalTo: noTrackersIndicatorImage.centerXAnchor),
            noTrackersIndicatorView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        return noTrackersIndicatorView
    }()
    
    init(store: DataStore) {
        self.store = store
        categoryData = CategoryStore(dataStore: store)
        trackerData = TrackerStore(dataStore: store)
        trackerRecordData = TrackerRecordStore(dataStore: store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YPWhite")
        configureNavigationBar()
        dateFromDatePicker = prepareDate(date: datePicker.date)
        guard let date = dateFromDatePicker else { return }
        
        categories = prepareCategories(date: date)
        
        collection.register(TrackerListItem.self, forCellWithReuseIdentifier: TrackerListItem.reuseIdentifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        
        view.addSubview(collection)
        
        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        trackerData?.delegate = self
        trackerRecordData?.delegate = self
        
        updateTrackers()
        placeholderIfNeeded()
    }
    
    private func prepareCategories(date: Date, searchText: String? = nil) -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        if let categories = categoryData?.getCategories() {
            //print(categories)
            let weekDay = getWeekDay()
            var searchQuery = ""
            if let searchText = searchText { searchQuery = searchText }
            for category in categories {
                //print(category)
                if let trackerData = trackerData {
                    let filteredTrackers = trackerData.getTrackers()
                    /*
                    let filteredTrackers = trackerData.getTrackers().filter {
                        var days = false
                        if let schedule = $0.schedule {
                            days = schedule.daysOfweek().contains(weekDay)
                        }
                        if searchQuery.count > 0 {
                            return ($0.categoryId == category.id && days && $0.title.lowercased().contains(searchQuery.lowercased())) || ($0.categoryId == category.id && $0.schedule == nil && $0.title.lowercased().contains(searchQuery.lowercased()))
                        } else {
                            print($0)
                            return $0.categoryId == category.id && days || ($0.categoryId == category.id && $0.schedule == nil)// || true
                        }
                    }
                    */
                    if filteredTrackers.count > 0 {
                        result.append(TrackerCategory(categoryId: category.id, trackers: filteredTrackers))
                    }
                }
            }
            return result
        } else {
            return []
        }
    }
    
    private func placeholderIfNeeded() {
        if noTrackersView.isDescendant(of: collection) {
            noTrackersView.removeFromSuperview()
        }
        if noTrackersFoundView.isDescendant(of: collection) {
            noTrackersFoundView.removeFromSuperview()
        }
        if !isFiltering {
            if categories?.count == 0 {
                collection.addSubview(noTrackersView)
                NSLayoutConstraint.activate([
                    noTrackersView.centerXAnchor.constraint(equalTo: collection.centerXAnchor),
                    noTrackersView.centerYAnchor.constraint(equalTo: collection.centerYAnchor)
                ])
            } else {
                if noTrackersView.isDescendant(of: collection) {
                    noTrackersView.removeFromSuperview()
                }
            }
        } else {
            if visibleCategories?.count == 0 {
                collection.addSubview(noTrackersFoundView)
                NSLayoutConstraint.activate([
                    noTrackersFoundView.centerXAnchor.constraint(equalTo: collection.centerXAnchor),
                    noTrackersFoundView.centerYAnchor.constraint(equalTo: collection.centerYAnchor)
                ])
            } else {
                if noTrackersFoundView.isDescendant(of: collection) {
                    noTrackersFoundView.removeFromSuperview()
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.font: UIFont(name: "YSDisplay-Bold", size: 34) ?? "System"]
        navigationItem.standardAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Add tracker"),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "YPBlack")
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(updateTrackers), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
    }
    
    private func getWeekDay() -> Int {
        guard let currentDate = dateFromDatePicker else { return 0 }
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: currentDate)
        return weekDay
    }
    
    @objc private func addTracker() {
        let createNewTrackerVC = CreateNewTrackerViewController(store: store)
        createNewTrackerVC.completionCancel = { [weak self] in
            self?.dismiss(animated: true)
        }
        createNewTrackerVC.completionCreate = { [weak self] in
            self?.updateTrackers()
            self?.dismiss(animated: true)
        }
        present(createNewTrackerVC, animated: true)
    }
    
    private func prepareDate(date: Date) -> Date? {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let shortDate = dateFormatter.string(from: date)
        let longDate = "\(shortDate)T00:00:00+0000"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let result = dateFormatter.date(from: longDate) {
            return result
        } else {
            return nil
        }
    }
    
    @objc private func checkDone(sender: DoneButton) {
        guard let dateFromDatePicker = dateFromDatePicker,
              let date = prepareDate(date: dateFromDatePicker)
        else { return }
        do {
            try trackerRecordData?.addTrackerRecord(doneAt: date, trackerId: sender.tag)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func updateTrackers() {
        dateFromDatePicker = prepareDate(date: datePicker.date)
        trackerData?.dateFromDatePicker = dateFromDatePicker
        guard let currentDate = dateFromDatePicker else { return }
        categories = prepareCategories(date: currentDate)
        collection.reloadData()
        placeholderIfNeeded()
    }
    
    func didUpdate() {
        updateTrackers()
    }
}

extension TrackerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        trackerData?.numberOfSectionsForTrackers() ?? 0
        /*
        if isFiltering {
            return visibleCategories?.count ?? 0
        }
        return categories?.count ?? 0
         */
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerData?.numberOfRowsInSectionForTrackers(section) ?? 0
        /*
        if isFiltering {
            return visibleCategories?[section].trackers.count ?? 0
        }
        return categories?[section].trackers.count ?? 0
         */
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerListItem.reuseIdentifier, for: indexPath) as? TrackerListItem,
              let tracker = trackerData?.object(at: indexPath),
              let dateFromDatePicker = dateFromDatePicker,
              let date = prepareDate(date: dateFromDatePicker),
              let done = trackerRecordData?.isTrackerDone(atDate: date, trackerId: tracker.id)
              //let color = tracker.color
              //let tracker = isFiltering ? visibleCategories?[indexPath.section].trackers[indexPath.row] : categories?[indexPath.section].trackers[indexPath.row]
        else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        
        let color = tracker.color ?? const.defaultColor
        
        cell.itemBackground.backgroundColor = UIColor(named: color)
        cell.icon.text = tracker.emoji
        cell.title.text = tracker.title
        cell.doneButton.isEnabled = !done
        cell.doneButton.backgroundColor = UIColor(named: color)
        cell.doneButton.tag = Int(tracker.id)
        cell.doneButton.addTarget(self, action: #selector(checkDone), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 2) - 4, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        //print("categories = \(categories)")
        //print("viewForSupplementaryElementOfKind indexPath = \(indexPath.section)")
        //print("categories[\(indexPath.section)] = \(categories?[indexPath.section])")
        view.titleLabel.text = categoryData?.getCategoryNameById(id: categories?[indexPath.section].categoryId ?? 0)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}

extension TrackerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        guard let currentDate = dateFromDatePicker,
              isFiltering,
              searchText.count > 0
        else {
            updateTrackers()
            return
        }
        visibleCategories = prepareCategories(date: currentDate, searchText: searchText)
        collection.reloadData()
        placeholderIfNeeded()
    }
}

final class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YPWhite")
        title = "Статистика"
    }
}

final class TabBarViewController: UITabBarController {
    private let trackerListVC = UINavigationController(rootViewController: TrackerListViewController(store: DataStore()))
    private let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
    
    override func viewDidLoad() {
        trackerListVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "iconTrackers"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "iconStatistics"), tag: 1)
        viewControllers = [trackerListVC, statisticsVC]
    }
}
