import UIKit

final class CategoriesViewCotroller: UIViewController {
    var store: DataStore
    private let categoriesTableView = UITableView()
    private var lastCategoriesCount: Int = 0
    private var selectedCategory: TrackerCategoryCoreData?
    var categoryUpdateCompletion: (() -> Void)?
    
    private var viewModel: CategoriesViewModel?
    
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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
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
        
        /* --------------------------------------------------------------- */
        
        //placeholderIfNeeded()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.onCategoriesChange = { [weak self] in
            print("onCategoriesChange closure called")
            self?.categoriesTableView.reloadData()
        }
    }

    private func updateCategories() {
        //viewModel?.updateCategories()
    }
    
    func showPlaceholder() {
        categoriesTableView.addSubview(noCategoriesView)
        NSLayoutConstraint.activate([
            noCategoriesView.centerXAnchor.constraint(equalTo: categoriesTableView.centerXAnchor),
            noCategoriesView.centerYAnchor.constraint(equalTo: categoriesTableView.centerYAnchor)
        ])
    }
    
    func hidePlaceholder() {
        if noCategoriesView.isDescendant(of: categoriesTableView) {
            noCategoriesView.removeFromSuperview()
        }
    }
    /*
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
    */
    @objc private func addCategory() {
        guard let viewModel = viewModel else { return }
        let addCategoryVC = AddCategoryViewController(data: viewModel.model/*store: store*/)
        addCategoryVC.completion = { [weak self] in
            //self?.updateCategories()
            self?.viewModel?.updateCategories()
            self?.dismiss(animated: true)
        }
        present(addCategoryVC, animated: true)
    }
}
/*
extension CategoriesViewCotroller: DataStoreDelegate {
    func didUpdate() {
        categoriesTableViewIds = []
        categoriesTableView.reloadData()
        //placeholderIfNeeded()
    }
}
*/
extension CategoriesViewCotroller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(viewModel?.categoriesCount())
        return viewModel?.categoriesCount() ?? 0
        //return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.reuseIdentifier, for: indexPath) as? CategoryListCell
        else { return CategoryListCell() }
        
        let cellViewModel = viewModel.getCategoryCellViewModel(at: indexPath)
        let categoriesCount = viewModel.categoriesCount()
        
        cell.configCell(number: indexPath.row + 1, of: categoriesCount)
        cell.cellViewModel = cellViewModel

        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self,
                          let viewModel = self.viewModel
                    else { return }
                    let addCategoryVC = AddCategoryViewController(data: viewModel.model/*store: self.store*/)
                    addCategoryVC.renameCompletion = { [weak self] in
                        viewModel.updateCategories()
                        self?.categoryUpdateCompletion?()
                    }
                    addCategoryVC.categoryId = viewModel.getCategory(at: indexPath) //self.categoriesTableViewIds[indexPath.row]
                    self.lastCategoriesCount = viewModel.categoriesCount() //self.data?.count ?? 0
                    self.present(addCategoryVC, animated: true)
                },
                
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    guard let self = self,
                          let viewModel = self.viewModel
                    else { return }
                    viewModel.deleteCategory(at: indexPath)
                    //viewModel.updateCategories()
                }
            ])
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.categoryTap(indexPath)
    }
    
}
