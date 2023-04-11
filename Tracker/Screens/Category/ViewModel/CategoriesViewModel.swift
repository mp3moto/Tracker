import Foundation

final class CategoriesViewModel: DataStoreDelegate {
    var onCategoriesChange: (() -> Void)?
    private var selectedCategory: TrackerCategoryCoreData?

    var model: CategoryStore //CategoriesModel
    var categorySelectCompletion: ((_: TrackerCategoryCoreData) -> Void)?
    //var categoryCellViewModels: [CategoryViewModel] = []
    var categoryCellViewModels = [CategoryViewModel]() {
        didSet {
            onCategoriesChange?()
            print(categoryCellViewModels.count)
        }
    }
    
    init(model: CategoryStore /*CategoriesModel*/, selectedCategory: TrackerCategoryCoreData?) {
        self.model = model
        self.model.delegate = self
        if let selectedCategory = selectedCategory {
            self.selectedCategory = selectedCategory
        }
        updateCategories()
    }
    
    func categoryTap(_ indexPath: IndexPath) {
        guard let selectedCategory = model.getCategory(indexPath) /*model.selectCategory(indexPath)*/ else { return }
        categorySelectCompletion?(selectedCategory)
    }
    
    func updateCategories() {
        let categories = model.getCategories()
        var tempArray: [CategoryViewModel] = []
        
        categories.forEach {
            tempArray.append(CategoryViewModel(name: $0.name ?? Const.noName, selected: $0 == selectedCategory))
        }
        categoryCellViewModels = tempArray
        //onCategoriesChange?()
    }
    
    func categoriesCount() -> Int {
        //updateCategories()
        return categoryCellViewModels.count
    }
    
    func getCategoryCellViewModel(at: IndexPath) -> CategoryViewModel {
        categoryCellViewModels[at.row]
    }
    
    func getCategory(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        //model.selectCategory(indexPath)
        model.getCategory(indexPath)
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard let categoryToDelete = model.getCategory(indexPath) else { return }
        try? model.deleteCategory(categoryToDelete)
        updateCategories()
    }
    
    func didUpdate() {
        print("CategoriesViewModel didUpdate")
        onCategoriesChange?()
    }
}
