import UIKit

final class CategoriesViewCotroller: UIViewController {
    private var selectedCategory: TrackerCategoryCoreData?
    var categoryUpdateCompletion: (() -> Void)?
    
    private var viewModel: CategoriesViewModel
    
    private let titleView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString.category
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addCategoryButton = YPButton(text: LocalizedString.addCategory, destructive: false)
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let noCategoriesView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "no trackers"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = LocalizedString.categoriesPlaceholder
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
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(titleView)
        view.addSubview(titleLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(categoriesTableView)
        
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        categoriesTableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.reuseIdentifier)
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        placeholderIfNeeded()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 63),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 27),
            
            addCategoryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            categoriesTableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            categoriesTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            categoriesTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        viewModel.onCategoriesChange = { [weak self] in
            guard let self = self else { return }
            self.categoriesTableView.reloadData()
            self.placeholderIfNeeded()
        }
    }
    
    private func showPlaceholder() {
        categoriesTableView.addSubview(noCategoriesView)
        NSLayoutConstraint.activate([
            noCategoriesView.centerXAnchor.constraint(equalTo: categoriesTableView.centerXAnchor),
            noCategoriesView.centerYAnchor.constraint(equalTo: categoriesTableView.centerYAnchor)
        ])
    }
    
    private func hidePlaceholder() {
        if noCategoriesView.isDescendant(of: categoriesTableView) {
            noCategoriesView.removeFromSuperview()
        }
    }
    
    private func placeholderIfNeeded() {
        viewModel.categoriesCount() > 0 ? hidePlaceholder() : showPlaceholder()
    }
    
    @objc private func addCategory() {
        let addCategoryVC = AddCategoryViewController(data: viewModel.model, category: selectedCategory)
        addCategoryVC.completion = { [weak self] in
            self?.viewModel.updateCategories()
            self?.dismiss(animated: true)
        }
        present(addCategoryVC, animated: true)
    }
}

extension CategoriesViewCotroller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.reuseIdentifier, for: indexPath) as? CategoryListCell
        else { return CategoryListCell() }
        
        let cellViewModel = viewModel.getCategoryCellViewModel(at: indexPath)
        cell.cellViewModel = cellViewModel

        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: LocalizedString.edit) { [weak self] _ in
                    guard let self = self else { return }
                    let addCategoryVC = AddCategoryViewController(data: self.viewModel.model, category: self.viewModel.getCategory(at: indexPath))
                    addCategoryVC.renameCompletion = { [weak self] in
                        self?.viewModel.updateCategories()
                        self?.categoryUpdateCompletion?()
                        self?.dismiss(animated: true)
                    }
                    //self.lastCategoriesCount = self.viewModel.categoriesCount()
                    self.present(addCategoryVC, animated: true)
                },
                
                UIAction(title: LocalizedString.delete, attributes: .destructive) { [weak self] _ in
                    self?.viewModel.deleteCategory(at: indexPath)
                    //TODO: Если ранее была выбрана категория и ее удалить, то в newTrackerVC остается ссылка не нее. Надо исправить
                }
            ])
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.categoryTap(indexPath)
    }
    
}
