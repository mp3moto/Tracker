import Foundation

final class CategoriesViewModel {
    var onCategoriesChange: (() -> Void)?
    private var selectedCategory: TrackerCategoryCoreData?
    var model: CategoryStore
    var categorySelectCompletion: ((_: TrackerCategoryCoreData) -> Void)?
    private var categoryCellViewModels = [CategoryViewModel]() {
        didSet {
            onCategoriesChange?()
        }
    }
    
    init(model: CategoryStore, selectedCategory: TrackerCategoryCoreData?) {
        self.model = model
        if let selectedCategory = selectedCategory {
            self.selectedCategory = selectedCategory
        }
        updateCategories()
    }
    
    func categoryTap(_ indexPath: IndexPath) {
        guard let selectedCategory = model.getCategory(indexPath) else { return }
        categorySelectCompletion?(selectedCategory)
    }
    
    func updateCategories() {
        let categories = model.getCategories()
        var tempArray: [CategoryViewModel] = []
        
        for (index, item) in categories.enumerated() {
            tempArray.append(
                CategoryViewModel(
                    name: item.name,
                    selected: item == selectedCategory,
                    first: index == 0,
                    last: index == categories.count - 1
                )
            )
        }

        categoryCellViewModels = tempArray
    }
    
    func categoriesCount() -> Int {
        model.numberOfRowsInSectionForCategories(0)
    }
    
    func getCategoryCellViewModel(at: IndexPath) -> CategoryViewModel {
        categoryCellViewModels[at.row]
    }
    
    func getCategory(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        model.object(at: indexPath)
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard let categoryToDelete = model.getCategory(indexPath),
              categoryToDelete != selectedCategory
        else { return }
        try? model.deleteCategory(categoryToDelete)
        updateCategories()
    }
}
