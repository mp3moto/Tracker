import UIKit

final class AddCategoryViewController: UIViewController {
    
    var completion: (() -> Void)?
    var category: Category?
    
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
        
        if let category = category {
            titleLabel.text = "Редактирование категории"
            addCategoryButton.setTitle("Готово", for: .normal)
            categoryName.text = category.name
            addCategoryButton.removeTarget(self, action: #selector(addCategory), for: .touchUpInside)
            addCategoryButton.tag = category.id
            addCategoryButton.addTarget(self, action: #selector(updateCategory), for: .touchUpInside)
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
        let data = DataManagement()
        _ = data.addCategory(name: categoryName.text ?? "Без названия")
        completion?()
        dismiss(animated: true)
    }
    
    @objc private func updateCategory(sender: YPButton) {
        let data = DataManagement()
        data.updateCategory(id: sender.tag, name: self.categoryName.text ?? "Без названия")
        completion?()
        dismiss(animated: true)
    }
}
