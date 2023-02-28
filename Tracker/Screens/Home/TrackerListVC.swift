import UIKit

final class TrackerListViewController: UIViewController {
    private let data = DataManagement()
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
    private var currentDate: Date?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        configureNavigationBar()
        currentDate = datePicker.date
        guard let currentDate = currentDate else { return }
        categories = prepareCategories(date: currentDate)
        
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
        
        updateTrackers()
        placeholderIfNeeded()
    }
    
    private func prepareCategories(date: Date, searchText: String? = nil) -> [TrackerCategory] {
        let categories = data.categories
        let weekDay = getWeekDay()
        var result: [TrackerCategory] = []
        var searchQuery = ""
        if let searchText = searchText { searchQuery = searchText }
        for category in categories {
            var filteredTrackers: [Tracker]
            if searchQuery.count > 0 {
                filteredTrackers = data.trackers.filter { ($0.categoryId == category.id && $0.schedule != nil && $0.schedule!.daysOfweek().contains(weekDay) && $0.title.lowercased().contains(searchQuery.lowercased())) || $0.categoryId == category.id && $0.schedule == nil && $0.title.lowercased().contains(searchQuery.lowercased()) }
            } else {
                filteredTrackers = data.trackers.filter { ($0.categoryId == category.id && $0.schedule != nil && $0.schedule!.daysOfweek().contains(weekDay)) || $0.categoryId == category.id && $0.schedule == nil }
            }
            if filteredTrackers.count > 0 {
                result.append(TrackerCategory(categoryId: Int(category.id), trackers: filteredTrackers))
            }
        }
        return result
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
        guard let currentDate = currentDate else { return 0 }
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: currentDate)
        return weekDay
    }
    
    @objc private func addTracker() {
        let createNewTrackerVC = CreateNewTrackerViewController()
        createNewTrackerVC.completionCancel = { [weak self] in
            self?.dismiss(animated: true)
        }
        createNewTrackerVC.completionCreate = { [weak self] in
            self?.updateTrackers()
            self?.dismiss(animated: true)
        }
        present(createNewTrackerVC, animated: true)
    }
    
    private func dateForCompletedTrackers() -> Date? {
        guard let date = currentDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let shortDate = dateFormatter.string(from: date)
        let longDate = "\(shortDate)T00:00:00+0000"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: longDate)
    }
    
    @objc private func checkDone(sender: DoneButton) {
        if completedTrackers == nil { completedTrackers = [] }
        if let trackerDate = dateForCompletedTrackers() {
            if completedTrackers?.filter({ $0.trackerId == sender.tag && $0.doneAt == trackerDate }).count == 0 {
                completedTrackers?.append(TrackerRecord(trackerId: sender.tag, doneAt: trackerDate))
                collection.reloadData()
            }
        }
    }
    
    @objc private func updateTrackers() {
        currentDate = datePicker.date
        guard let currentDate = currentDate else { return }
        categories = prepareCategories(date: currentDate)
        collection.reloadData()
        placeholderIfNeeded()
    }
}

extension TrackerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltering {
            return visibleCategories?.count ?? 0
        }
        return categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return visibleCategories?[section].trackers.count ?? 0
        }
        return categories?[section].trackers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerListItem.reuseIdentifier, for: indexPath) as? TrackerListItem,
              let tracker = isFiltering ? visibleCategories?[indexPath.section].trackers[indexPath.row] : categories?[indexPath.section].trackers[indexPath.row]
        else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        
        cell.itemBackground.backgroundColor = UIColor(named: tracker.color)
        cell.icon.text = tracker.emoji
        cell.title.text = tracker.title
        cell.doneButton.isEnabled = true
        
        if completedTrackers?.firstIndex(where: { $0.trackerId == tracker.id && $0.doneAt == dateForCompletedTrackers() }) != nil {
            cell.doneButton.isEnabled = false
        }
        
        cell.doneButton.backgroundColor = UIColor(named: tracker.color)
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
        
        view.titleLabel.text = data.getCategoryNameById(id: categories?[indexPath.section].categoryId ?? 0)
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
        guard let currentDate = currentDate,
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
    private let trackerListVC = UINavigationController(rootViewController: TrackerListViewController())
    private let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
    
    override func viewDidLoad() {
        trackerListVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "iconTrackers"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "iconStatistics"), tag: 1)
        viewControllers = [trackerListVC, statisticsVC]
    }
}
