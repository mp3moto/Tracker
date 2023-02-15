import UIKit

class NewTrackerViewController: UIViewController {
    var completion: (() -> Void)?
    var selectedCategory: Int?
    var selectedSchedule: Schedule? {
        didSet {
            checkState()
            trackerParamsTableView.reloadData()
        }
    }
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    let data = DataManagement()
    let trackerParamsTableView = UITableView()
    let trackerParamsTableViewValues: [String] = ["Категория", "Расписание"]
    
    let trackerName: UITextField = {
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
    
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let cancelButton = YPButton(text: "Отменить", destructive: true)
    let createButton = YPButton(text: "Создать", destructive: false)
    
    let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    let colors: [String] = ["Sunset Orange", "West Side", "Azure Radiance", "Electric Violet", "Emerald", "Orchid", "Azalea", "Dodger Blue", "Turquoise", "Minsk", "Persimmon", "Carnation Pink", "Manhattan", "Cornflower Blue", "Violet", "Medium Purple", "Purple", "Soft Emerald"]

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
            label.text = "Новая привычка"
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
        
        /*--------------------------TrackerParams-------------------------*/
        trackerParamsTableView.layer.cornerRadius = 16
        trackerParamsTableView.translatesAutoresizingMaskIntoConstraints = false
        trackerParamsTableView.isScrollEnabled = false
        pageContentView.addSubview(trackerParamsTableView)
        
        NSLayoutConstraint.activate([
            trackerParamsTableView.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            trackerParamsTableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24),
            trackerParamsTableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
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
    
    @objc func cancelCreation() {
        completion?()
    }
    
    @objc private func createTracker() {
        _ = data.addTracker(title: trackerName.text, emoji: selectedEmoji, color: selectedColor, schedule: selectedSchedule)
        completion?()
    }
    
    @objc func setCategory(id: Int) {
        selectedCategory = data.categories?[id].id
        checkState()
        trackerParamsTableView.reloadData()
    }
    
    @objc func checkState() {
        createButton.isEnabled = trackerIsReadyToBeCreated()
    }
    
    func setSchedule() {
        trackerParamsTableView.reloadData()
    }
    
    func trackerIsReadyToBeCreated() -> Bool {
        guard let category = selectedCategory,
              let schedule = selectedSchedule,
              let _ = selectedEmoji,
              let _ = selectedColor
        else { return false }
        let trackerNameLength = trackerName.text?.count ?? 0
        let trackerNameIsOK = trackerNameLength > 0 && trackerNameLength <= 38
        let categoryIsOK = category > 0
        let scheduleIsOK = !schedule.isEmpty()
        
        return trackerNameIsOK && categoryIsOK && scheduleIsOK
    }
}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerParamsTableViewValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerListCell.reuseIdentifier, for: indexPath) as? TrackerListCell else { return TrackerListCell() }
        if indexPath.row == 0 {
            cell.cellValueText = data.categories?.first(where: { $0.id == selectedCategory })?.name
        } else {
            cell.cellValueText = selectedSchedule?.text()
        }
        cell.cellText = trackerParamsTableViewValues[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == trackerParamsTableViewValues.count - 1 {
            cell.separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let categoriesVC = CategoriesViewCotroller()
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
            cell.symbol.text = emoji[indexPath.row]
            cell.layer.cornerRadius = 16
            return cell
        case colorCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
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
