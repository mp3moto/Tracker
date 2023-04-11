import UIKit

final class AddCategoryViewController: UIViewController {
    //private let store: DataStore
    private let data: CategoryStore
    var completion: (() -> Void)?
    var renameCompletion: (() -> Void)?
    var categoryId: TrackerCategoryCoreData?
    
    //private let data: CategoryStore?
    
    private let categoryName: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
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
    
    private let addCategoryButton = YPButton(text: "Добавить категорию", destructive: false)
    
    init(data: CategoryStore/*store: DataStore*/) {
        //self.store = store
        //data = CategoryStore(dataStore: store)
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
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
            label.text = "Новая категория"
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
        
        /*---------------------------CategoryName--------------------------*/
        categoryName.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        view.addSubview(categoryName)
        
        NSLayoutConstraint.activate([
            categoryName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            categoryName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryName.heightAnchor.constraint(equalToConstant: 75),
            categoryName.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24)
        ])
        /*----------------------------------------------------------------*/
        
        /* ---------------------------- Button --------------------------*/
        
        addCategoryButton.isEnabled = false
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            addCategoryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        /*--------------------------------------------------------------- */
        
        if let categoryId = categoryId {
            if let category = data.getCategory(categoryId) {
                titleLabel.text = "Редактирование категории"
                addCategoryButton.setTitle("Готово", for: .normal)
                categoryName.text = category.name
                addCategoryButton.removeTarget(self, action: #selector(addCategory), for: .touchUpInside)
                addCategoryButton.addTarget(self, action: #selector(updateCategory), for: .touchUpInside)
            } else {
                dismiss(animated: true)
            }
        }
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
            print(error.localizedDescription)
        }
    }
    
    @objc private func updateCategory(sender: YPButton) {
        guard let categoryId = categoryId else { return }
        //let data = CategoryStore(dataStore: store)
        do {
            try data.updateCategory(id: categoryId, name: categoryName.text ?? Const.noName)
            renameCompletion?()
            dismiss(animated: true)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
