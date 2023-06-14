import UIKit

final class FiltersViewController: UIViewController {
    private var viewModel: FiltersViewModel
    
    private let titleView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString.filters
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(viewModel: FiltersViewModel) {
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
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(titleView)
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
        
        filtersTableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.reuseIdentifier)
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 63),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 27),
            
            filtersTableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24),
            filtersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            filtersTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filtersCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.reuseIdentifier, for: indexPath) as? CategoryListCell
        else { return CategoryListCell() }
        
        let cellViewModel = viewModel.getCategoryCellViewModel(at: indexPath)
        cell.cellViewModel = cellViewModel

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.filterTap(indexPath)
    }
}
