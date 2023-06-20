import UIKit

final class TrackerListViewController: UIViewController, DataStoreDelegate {
    private let trackerStore: TrackerStore
    private let categoryStore: CategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private let dateFormatter = DateFormatter()
    private let searchController = UISearchController(searchResultsController: nil)
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var categories: [TrackerCategory]?
    private var trackerIds: [TrackerCoreData] = []
    private var trackersFilter: TrackersFilter = .all {
        didSet {
            updateTrackers()
        }
    }
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text,
              text.count > 0
        else { return true }
        return false
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.maximumDate = Date()
        return datePicker
    }()
    private var dateFromDatePicker: Date? {
        didSet {
            trackerStore.dateFromDatePicker = dateFromDatePicker
        }
    }
    
    private let noTrackersView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "no trackers"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = LocalizedString.whatWillWeTrack
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
        noTrackersIndicatorLabel.text = LocalizedString.nothingFound
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
    
    private let filtersButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlue")
        button.setTitle(LocalizedString.filters, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Regular", size: 17)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emptyViewForCellContextMenuWhenGuardExecuted = UIView(frame: .zero)
    private let analyticsServices: AnalyticsServicesProtocol?
    private let screenName = "Main"
    
    init(trackerStore: TrackerStore, categoryStore: CategoryStore, trackerRecordStore: TrackerRecordStore, analyticsServices: AnalyticsServicesProtocol? = nil) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.trackerRecordStore = trackerRecordStore
        self.analyticsServices = analyticsServices
        trackerStore.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        /* for screenshotTest */
            //view.backgroundColor = .green
        //------------------
        configureNavigationBar()
        dateFromDatePicker = datePicker.date.prepareDate()
        guard let date = dateFromDatePicker else { return }
        trackerStore.dateFromDatePicker = date
        
        categories = prepareCategories()
        
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
        
        trackerStore.delegate = self
        trackerRecordStore.delegate = self

        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17)
        ])
        
        filtersButton.addTarget(self, action: #selector(showFilteringMenu), for: .touchUpInside)
        
        placeholderIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsServices?.openScreen(screen: screenName)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsServices?.closeScreen(screen: screenName)
    }
    
    private func prepareCategories() -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        let filteredTrackers = trackerStore.getTrackers(filter: trackersFilter)

        var categoryNames: Set<String> = []
        
        filteredTrackers.forEach {
            categoryNames.insert($0.category)
        }
        var categoryNamesSorted = categoryNames.sorted()
        if let pinnedIndex = categoryNamesSorted.firstIndex(of: LocalizedString.pinned) {
            categoryNamesSorted.remove(at: pinnedIndex)
            categoryNamesSorted.insert(LocalizedString.pinned, at: 0)
        }
        categoryNamesSorted.forEach {
            let currentCategory = $0
            result.append(TrackerCategory(category: currentCategory, trackers: filteredTrackers.filter { $0.category == currentCategory }))
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
            if categories?.count == 0 {
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
        
        title = LocalizedString.trackers
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
        searchController.searchBar.placeholder = LocalizedString.search
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
        analyticsServices?.tapOn(element: Const.analyticsIdentifierForAddButton)
        
        let createNewTrackerVC = CreateNewTrackerViewController(trackerStore: trackerStore, categoryStore: categoryStore)
        createNewTrackerVC.completionCancel = { [weak self] in
            self?.dismiss(animated: true)
        }
        createNewTrackerVC.completionCreate = { [weak self] in
            self?.updateTrackers()
            self?.dismiss(animated: true)
        }
        present(createNewTrackerVC, animated: true)
    }
    
    @objc private func checkDone(sender: DoneButton) {
        guard let date = dateFromDatePicker else { return }
        do {
            analyticsServices?.tapOn(element: Const.analyticsIdentifierForTracker)
            try trackerRecordStore.toggleTrackerRecord(doneAt: date, trackerId: trackerIds[sender.tag])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func updateTrackers() {
        trackerIds = []
        dateFromDatePicker = datePicker.date.prepareDate()
        categories = prepareCategories()
        collection.reloadData()
        placeholderIfNeeded()
    }
    
    @objc private func deleteConfirmationDialog(tracker: TrackerCoreData) {
        let deleteDialog = UIAlertController(title: LocalizedString.deleteTrackerConfirmation, message: nil, preferredStyle: .actionSheet)
        
        deleteDialog.addAction(UIAlertAction(title: LocalizedString.delete, style: .destructive) { [weak self] _ in
            try? self?.trackerStore.deleteTracker(tracker: tracker)
        })
        deleteDialog.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel))

        present(deleteDialog, animated: true)
    }
    
    @objc private func showFilteringMenu() {
        analyticsServices?.tapOn(element: Const.analyticsIdentifierForFilterButton)
        
        let filtersViewModel = FiltersViewModel(selectedFilter: trackersFilter)
        filtersViewModel.onFilterSelect = { [weak self] selectedFilter in
            self?.trackersFilter = selectedFilter
            self?.dismiss(animated: true)
        }
        
        let filtersVC = FiltersViewController(viewModel: filtersViewModel)
        present(filtersVC, animated: true)
    }
    
    func didUpdate() {
        updateTrackers()
    }
}

extension TrackerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout/*, UIContextMenuInteractionDelegate*/ {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories?[section].trackers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerListItem.reuseIdentifier, for: indexPath) as? TrackerListItem,
              let tracker = categories?[indexPath.section].trackers[indexPath.row]
        else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        
        let color = tracker.color
        
        cell.itemBackground.backgroundColor = UIColor(named: color)
        cell.icon.text = tracker.emoji
        cell.title.text = tracker.title
        cell.doneLabel.text = String.localizedStringWithFormat(NSLocalizedString("daysDone", comment: ""), tracker.doneCount)
        cell.doneButton.stateEnabled = !tracker.done
        cell.doneButton.backgroundColor = UIColor(named: color)
        cell.showPinnedIcon(tracker.pinned)
        trackerIds.append(tracker.id)
        cell.doneButton.tag = trackerIds.endIndex - 1
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
        view.titleLabel.text = categories?[indexPath.section].category
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard !indexPaths.isEmpty,
              let tracker = self.categories?[indexPaths[0].section].trackers[indexPaths[0].row] else { return nil }
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: tracker.pinned ? LocalizedString.unpin : LocalizedString.pin) { [weak self] _ in
                    try? self?.trackerStore.togglePinned(trackerId: tracker.id)
                },
                
                UIAction(title: LocalizedString.edit) { [weak self] _ in
                    guard let self = self else { return }
                    self.analyticsServices?.tapOn(element: Const.analyticsIdentifierForTrackerContextMenuEdit)
                    var trackerType: TrackerType = .event
                    if let _ = tracker.schedule {
                        trackerType = .habit
                    }
                    let trackerVC = NewTrackerViewController(trackerType: trackerType, trackerStore: self.trackerStore, categoryStore: self.categoryStore, editTracker: tracker.id)
                    trackerVC.completionCancel = { [weak self] in
                        self?.dismiss(animated: true)
                    }
                    trackerVC.completionCreate = { [weak self] in
                        self?.updateTrackers()
                        self?.dismiss(animated: true)
                    }
                    self.present(trackerVC, animated: true)
                },
                
                UIAction(title: LocalizedString.delete, attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    self.analyticsServices?.tapOn(element: Const.analyticsIdentifierForTrackerContextMenuDelete)
                    self.deleteConfirmationDialog(tracker: tracker.id)
                }
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerListItem
        else { return UITargetedPreview(view: emptyViewForCellContextMenuWhenGuardExecuted)}
        
        return UITargetedPreview(view: cell.getContextMenuPreview())
    }
}

extension TrackerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              searchText.count > 0,
              searchController.isActive
        else {
            trackerStore.searchQuery = ""
            updateTrackers()
            return
        }
        trackerStore.searchQuery = searchText
        updateTrackers()
    }
}
