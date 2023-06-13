import UIKit

final class AddCategoryViewController: UIViewController {
    private let data: CategoryStore
    var completion: (() -> Void)?
    var renameCompletion: (() -> Void)?
    private var category: TrackerCategoryCoreData?
    
    private let titleView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString.newCategory
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryName: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(string: LocalizedString.enterCategoryName, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YPTextFieldPlaceholder") ?? .gray])
        field.font = UIFont(name: "YSDisplay-Medium", size: 17)
        field.layer.cornerRadius = 16
        field.backgroundColor = UIColor(named: "YPTextFieldBackground")
        field.clearButtonMode = .always
        field.leftViewMode = .always
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        
        switch UIView.userInterfaceLayoutDirection(for: field.semanticContentAttribute) {
        case .leftToRight:
            field.textAlignment = .left
        case .rightToLeft:
            field.textAlignment = .right
        @unknown default:
            break
        }
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let addCategoryButton = YPButton(text: LocalizedString.done, destructive: false)
    
    init(data: CategoryStore, category: TrackerCategoryCoreData? = nil) {
        self.data = data
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleView)
        view.addSubview(titleLabel)
        view.addSubview(categoryName)
        view.addSubview(addCategoryButton)
        
        categoryName.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        
        if let category = category {
            if let category = data.getCategoryStruct(category) {
                titleLabel.text = LocalizedString.editCategory
                addCategoryButton.setTitle(LocalizedString.done, for: .normal)
                categoryName.text = category.name
                addCategoryButton.addTarget(self, action: #selector(updateCategory), for: .touchUpInside)
            } else {
                dismiss(animated: true)
            }
        } else {
            addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        }
        addCategoryButton.isEnabled = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 63),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 27),
            
            categoryName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            categoryName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryName.heightAnchor.constraint(equalToConstant: 75),
            categoryName.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24),
            
            addCategoryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func textFieldChanged(_ sender: UITextInput) {
        guard let textLength = categoryName.text?.count,
              textLength > 0,
              textLength < 25 else {
            addCategoryButton.isEnabled = false
            return
        }
        addCategoryButton.isEnabled = true
    }
    
    @objc private func addCategory() {
        do {
            try data.addCategory(name: categoryName.text ?? Const.noName)
            completion?()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    @objc private func updateCategory(sender: YPButton) {
        guard let category = category else { return }
        do {
            try data.updateCategory(id: category, name: categoryName.text ?? Const.noName)
            renameCompletion?()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
