import UIKit

final class CategoriesViewCotroller: UIViewController {
    private let store: DataStore
    private let data: CategoryStore?
    private let categoriesTableView = UITableView()
    private var lastCategoriesCount: Int = 0
    private var categoriesTableViewIds: [Int32] = []
    weak var parentVC: NewTrackerViewController?
    var categoryCompletion: (() -> Void)?
    
    private let noCategoriesView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "no trackers"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = "Привычки и события можно\nобъединить по смыслу"
        noTrackersIndicatorLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        noTrackersIndicatorLabel.numberOfLines = 2
        noTrackersIndicatorLabel.textAlignment = .center
        
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
            noTrackersIndicatorLabel.heightAnchor.constraint(equalToConstant: 36),
            noTrackersIndicatorView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        return noTrackersIndicatorView
    }()
    
    init(store: DataStore) {
        self.store = store
        data = CategoryStore(dataStore: store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        /* -------------------------- TITLE -------------------------- */
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
            label.text = "Категория"
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
        
        /* ---------------------------- Button -------------------------- */
        let addCategoryButton = YPButton(text: "Добавить категорию", destructive: false)
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            addCategoryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        /* --------------------------------------------------------------- */
        
        /* -------------------------- TableView -------------------------- */
        
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        categoriesTableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.reuseIdentifier)
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        view.addSubview(categoriesTableView)
        
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            categoriesTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            categoriesTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        placeholderIfNeeded()
        
        /* --------------------------------------------------------------- */
        data?.delegate = self
    }

    private func updateCategories() {
        categoriesTableViewIds = []
        categoriesTableView.reloadData()
        placeholderIfNeeded()
    }
    
    private func placeholderIfNeeded() {
        if data?.getCategories().count == 0 {
            categoriesTableView.addSubview(noCategoriesView)
            NSLayoutConstraint.activate([
                noCategoriesView.centerXAnchor.constraint(equalTo: categoriesTableView.centerXAnchor),
                noCategoriesView.centerYAnchor.constraint(equalTo: categoriesTableView.centerYAnchor)
            ])
        } else {
            if noCategoriesView.isDescendant(of: categoriesTableView) {
                noCategoriesView.removeFromSuperview()
            }
        }
    }
    
    @objc private func addCategory() {
        let addCategoryVC = AddCategoryViewController(store: store)
        addCategoryVC.completion = { [weak self] in
            self?.updateCategories()
            self?.dismiss(animated: true)
        }
        if let _ = data?.getCategories().count {
            present(addCategoryVC, animated: true)
        }
    }
}

extension CategoriesViewCotroller: DataStoreDelegate {
    func didUpdate() {
        categoriesTableViewIds = []
        categoriesTableView.reloadData()
        placeholderIfNeeded()
    }
}

extension CategoriesViewCotroller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        return data.numberOfRowsInSectionForCategories(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let record = data?.object(at: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.reuseIdentifier, for: indexPath) as? CategoryListCell,
              let data = data
        else { return CategoryListCell() }

        categoriesTableViewIds.append(record.id)
        
        cell.cellText = record.name
        if parentVC?.selectedCategory ?? 0 == record.id {
            cell.checkmarkImage.isHidden = false
        } else {
            cell.checkmarkImage.isHidden = true
        }
        
        cell.layer.maskedCorners = []
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == data.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            cell.separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self else { return }
                    let addCategoryVC = AddCategoryViewController(store: self.store)
                    addCategoryVC.renameCompletion = { [weak self] in
                        self?.didUpdate()
                        self?.categoryCompletion?()
                    }
                    addCategoryVC.categoryId = self.categoriesTableViewIds[indexPath.row]
                    self.lastCategoriesCount = self.data?.count ?? 0
                    self.present(addCategoryVC, animated: true)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    //guard let row = indexPath.row else { self?.dismiss(animated: true) }
                    self?.data?.deleteCategory(self?.categoriesTableViewIds[indexPath.row] ?? 0)
                    self?.didUpdate()
                }
            ])
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC?.setCategory(id: categoriesTableViewIds[indexPath.row])
        //data.get
        dismiss(animated: true)
    }
    
}
