import UIKit

class NewTrackerViewController: UIViewController {
    
    let trackerParamsTableViewValues: [String] = ["Категория", "Расписание"]
    let emojiAndColorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        view.addSubview(titleLabel)
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
            pageContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pageContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            pageContentView.heightAnchor.constraint(equalToConstant: 840)
        ])
        /*----------------------------------------------------------------*/
        
        /*---------------------------TrackerName--------------------------*/
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
       
        pageContentView.addSubview(trackerName)
        
        NSLayoutConstraint.activate([
            trackerName.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            trackerName.topAnchor.constraint(equalTo: pageContentView.topAnchor, constant: 24)
        ])
        /*----------------------------------------------------------------*/
        
        /*--------------------------TrackerParams-------------------------*/
        let trackerParamsTableView = UITableView()
        trackerParamsTableView.layer.cornerRadius = 16
        trackerParamsTableView.translatesAutoresizingMaskIntoConstraints = false
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
        
        emojiAndColorCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiAndColorCollection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        emojiAndColorCollection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        emojiAndColorCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        emojiAndColorCollection.dataSource = self
        emojiAndColorCollection.delegate = self
        
        pageContentView.addSubview(emojiAndColorCollection)
        
        NSLayoutConstraint.activate([
            emojiAndColorCollection.topAnchor.constraint(equalTo: trackerParamsTableView.bottomAnchor, constant: 0),
            emojiAndColorCollection.heightAnchor.constraint(equalToConstant: 480),
            emojiAndColorCollection.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            emojiAndColorCollection.centerXAnchor.constraint(equalTo: pageContentView.centerXAnchor)
        ])
        /*----------------------------------------------------------------*/
        
        /*------------------------------Buttons---------------------------*/
        let cancelButton = YPButton(text: "Отменить", destructive: true)
        let createButton = YPButton(text: "Создать", destructive: false)
        createButton.isEnabled = false
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        pageContentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: pageContentView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: emojiAndColorCollection.bottomAnchor, constant: 16),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        /*----------------------------------------------------------------*/
    }
    
    @objc func cancelCreation() {
        dismiss(animated: true)
    }
}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return emoji.count
        case 1: return colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            cell.symbol.text = emoji[indexPath.row]
            cell.layer.cornerRadius = 16
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            cell.colorView.backgroundColor = UIColor(named: colors[indexPath.row])
            cell.layer.borderColor = UIColor(named: colors[indexPath.row])?.withAlphaComponent(0.3).cgColor
            cell.layer.cornerRadius = 12
            return cell
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
        switch indexPath.section {
        case 0:
            textLabel = "Emoji"
        default:
            textLabel = "Цвет"
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            cell.backgroundColor = UIColor(named: "YPGray")?.withAlphaComponent(1.0)
        default:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            cell.layer.borderWidth = 3
            
        }
        //print(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            cell.backgroundColor = UIColor(named: "YPWhite")
        default:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            cell.layer.borderWidth = 0
        }
        print(indexPath)
    }
    
    // TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerParamsTableViewValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerListCell.reuseIdentifier, for: indexPath) as? TrackerListCell else { return TrackerListCell() }
        
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
}
