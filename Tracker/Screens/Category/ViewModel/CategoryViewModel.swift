import Foundation

final class CategoryViewModel {
    var onChange: (() -> Void)?
    private(set) var name: String? {
        didSet {
            onChange?()
        }
    }
    private(set) var selected: Bool? {
        didSet {
            onChange?()
        }
    }
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
}
