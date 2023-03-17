import UIKit

class NewTrackerViewController: UIViewController {
    private let trackerType: String
    private let store: DataStore
    var completionCancel: (() -> Void)?
    var completionCreate: (() -> Void)?
    var selectedCategory: Int32?//TrackerCategoryCoreData?
    var selectedSchedule: Schedule? {
        didSet {
            checkState()
            trackerParamsTableView.reloadData()
        }
    }
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    private let trackerData: TrackerStore?
    private let categoryData: CategoryStore?
    private let trackerParamsTableView = UITableView()
    private var trackerParamsTableViewValues: [String]?
    
    private let trackerName: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.font = UIFont(name: "YSDisplay-Medium", size: 17)
        field.layer.cornerRadius = 16
        field.backgroundColor = UIColor(named: "YPGray")
        field.clearButtonMode = .always
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let trackerNameHint: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(const.trackerNameLengthLimit) символов"
        label.textColor = UIColor(named: "YPRed")
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var constraint1 = NSLayoutConstraint()
    var constraint2 = NSLayoutConstraint()
    
    private let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let cancelButton = YPButton(text: "Отменить", destructive: true)
    private let createButton = YPButton(text: "Создать", destructive: false)
    
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [String] = ["Sunset Orange", "West Side", "Azure Radiance", "Electric Violet", "Emerald", "Orchid", "Azalea", "Dodger Blue", "Turquoise", "Minsk", "Persimmon", "Carnation Pink", "Manhattan", "Cornflower Blue", "Violet", "Medium Purple", "Purple", "Soft Emerald"]
    
    init(trackerType: String, store: DataStore) {
        self.trackerType = trackerType
        self.store = store
        if trackerType == const.habit {
            trackerParamsTableViewValues = ["Категория", "Расписание"]
        } else {
            trackerParamsTableViewValues = ["Категория"]
        }
        trackerData = TrackerStore(dataStore: store)
        categoryData = CategoryStore(dataStore: store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        /* -------------------- TITLE -------------------------- */
        let titleView = UIView(frame: .zero)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 63)
        ])
        
        let titleLabel: UILabel = {
            let label = UILabel()
            if trackerType == "habit" {
                label.text = "Новая привычка"
            } else {
                label.text = "Новое нерегулярное событие"
            }
            label.font = UIFont(name: "YSDisplay-Medium", size: 16)
            label.textColor = UIColor(named: "YPBlack")
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        titleView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 27)
        ])
        /*----------------------------------------------------------------*/
         
        /*---------------------------ScrollView---------------------------*/
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let pageContentView = UIView()
        pageContentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(pageContentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            pageContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            pageContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            pageContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            pageContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        /*----------------------------------------------------------------*/
        
        /*---------------------------TrackerName--------------------------*/
        trackerName.addTarget(self, action: #selector(checkState), for: .allEditingEvents)
        pageContentView.addSubview(trackerName)
        
        NSLayoutConstraint.activate([
            trackerName.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            trackerName.topAnchor.constraint(equalTo: pageContentView.topAnchor, constant: 24)
        ])
        /*----------------------------------------------------------------*/
        
        /*-------------------------TrackerNameHint------------------------*/
        pageContentView.addSubview(trackerNameHint)
        NSLayoutConstraint.activate([
            trackerNameHint.leadingAnchor.constraint(equalTo: trackerName.leadingAnchor),
            trackerNameHint.trailingAnchor.constraint(equalTo: trackerName.trailingAnchor),
            trackerNameHint.heightAnchor.constraint(equalToConstant: 22),
            trackerNameHint.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 8)
        ])
        trackerNameHint.layer.opacity = 0
        /*----------------------------------------------------------------*/
        
        /*--------------------------TrackerParams-------------------------*/
        trackerParamsTableView.layer.cornerRadius = 16
        trackerParamsTableView.translatesAutoresizingMaskIntoConstraints = false
        trackerParamsTableView.isScrollEnabled = false
        pageContentView.addSubview(trackerParamsTableView)
        
        let trackerParamsTableViewRowsCount = trackerParamsTableViewValues?.count ?? 0
        
        NSLayoutConstraint.activate([
            trackerParamsTableView.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            //trackerParamsTableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24),
            trackerParamsTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerParamsTableViewRowsCount * 75))
        ])
        
        constraint1 = trackerParamsTableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24)
        constraint2 = trackerParamsTableView.topAnchor.constraint(equalTo: trackerNameHint.bottomAnchor, constant: 32)
        
        constraint1.isActive = true
        
        trackerParamsTableView.register(TrackerListCell.self, forCellReuseIdentifier: TrackerListCell.reuseIdentifier)
        
        trackerParamsTableView.dataSource = self
        trackerParamsTableView.delegate = self
        /*----------------------------------------------------------------*/
        
        /*---------------------------Collections--------------------------*/
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        colorCollection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        emojiCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        emojiCollection.dataSource = self
        colorCollection.dataSource = self
        
        emojiCollection.delegate = self
        colorCollection.delegate = self
        
        pageContentView.addSubview(emojiCollection)
        pageContentView.addSubview(colorCollection)

        NSLayoutConstraint.activate([
            emojiCollection.topAnchor.constraint(equalTo: trackerParamsTableView.bottomAnchor, constant: 0),
            emojiCollection.heightAnchor.constraint(equalToConstant: 240),
            emojiCollection.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            emojiCollection.centerXAnchor.constraint(equalTo: pageContentView.centerXAnchor),
            
            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 0),
            colorCollection.heightAnchor.constraint(equalToConstant: 240),
            colorCollection.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            colorCollection.centerXAnchor.constraint(equalTo: pageContentView.centerXAnchor)
        ])
        /*----------------------------------------------------------------*/
        
        /*------------------------------Buttons---------------------------*/
        
        createButton.isEnabled = false
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        pageContentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.bottomAnchor.constraint(equalTo: pageContentView.bottomAnchor)
        ])
        /*----------------------------------------------------------------*/
        
    }
        
    @objc private func cancelCreation() {
        completionCancel?()
    }
    
    @objc private func createTracker() throws {
        guard let title = trackerName.text,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let categoryId = selectedCategory
        else {
            return
        }
        do {
            _ = try trackerData?.addTracker(title: title, emoji: emoji, color: color, categoryId: categoryId, schedule: selectedSchedule)
            completionCreate?()
        } catch {
            print("error ocured while tracker created")
        }
    }
    
    @objc func setCategory(id: Int32) {
        selectedCategory = id
        checkState()
        trackerParamsTableView.reloadData()
    }
    
    @objc private func checkState() {
        let trackerNameLength = trackerName.text?.count ?? 0
        if trackerNameLength > const.trackerNameLengthLimit {
            constraint1.isActive = false
            constraint2.isActive = true
            trackerNameHint.layer.opacity = 1
        } else {
            constraint2.isActive = false
            constraint1.isActive = true
            trackerNameHint.layer.opacity = 0
        }
        
        createButton.isEnabled = trackerIsReadyToBeCreated()
    }
    
    private func setSchedule() {
        trackerParamsTableView.reloadData()
    }
    
    private func trackerIsReadyToBeCreated() -> Bool {
        guard let category = selectedCategory,
              let _ = selectedEmoji,
              let _ = selectedColor
        else { return false }
        let trackerNameLength = trackerName.text?.count ?? 0
        let trackerNameIsOK = trackerNameLength > 0 && trackerNameLength <= 38
        let categoryIsOK = category > 0
        if trackerType == const.habit {
            return selectedSchedule != nil && trackerNameIsOK && categoryIsOK
        } else {
            return trackerNameIsOK && categoryIsOK
        }
    }
    
    private func updateSelectedCategoryName() {
        trackerParamsTableView.reloadData()
    }
}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerParamsTableViewValues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerListCell.reuseIdentifier, for: indexPath) as? TrackerListCell else { return TrackerListCell() }
        if indexPath.row == 0 {
            cell.cellValueText = categoryData?.getCategories().first(where: { $0.id == selectedCategory })?.name
        } else {
            cell.cellValueText = selectedSchedule?.text()
        }
        cell.cellText = trackerParamsTableViewValues?[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let trackerParamsTableViewValues = trackerParamsTableViewValues else { return }
        if indexPath.row == trackerParamsTableViewValues.count - 1 {
            cell.separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let categoriesVC = CategoriesViewCotroller(store: store)
            categoriesVC.categoryCompletion = { [weak self] in
                self?.updateSelectedCategoryName()
            }
            categoriesVC.parentVC = self
            present(categoriesVC, animated: true)
        default:
            let scheduleVC = ScheduleViewCotroller()
            scheduleVC.parentVC = self
            scheduleVC.schedule = selectedSchedule
            present(scheduleVC, animated: true)
        }
    }
}

extension NewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollection: return emoji.count
        case colorCollection: return colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollection: guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            cell.prepareForReuse()
            cell.symbol.text = emoji[indexPath.row]
            cell.layer.cornerRadius = 16
            return cell
        case colorCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            cell.prepareForReuse()
            cell.colorView.backgroundColor = UIColor(named: colors[indexPath.row])
            cell.layer.borderColor = UIColor(named: colors[indexPath.row])?.withAlphaComponent(0.3).cgColor
            cell.layer.cornerRadius = 12
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var textLabel: String
        switch collectionView {
        case emojiCollection: textLabel = "Emoji"
        case colorCollection: textLabel = "Цвет"
        default: textLabel = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        
        view.titleLabel.text = textLabel
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollection: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            selectedEmoji = emoji[indexPath.row]
            cell.backgroundColor = UIColor(named: "YPGray")?.withAlphaComponent(1.0)
            checkState()
        case colorCollection:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            selectedColor = colors[indexPath.row]
            cell.layer.borderWidth = 3
            checkState()
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollection: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            cell.backgroundColor = UIColor(named: "YPWhite")
        case colorCollection:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            cell.layer.borderWidth = 0
        default: break
        }
    }
}
