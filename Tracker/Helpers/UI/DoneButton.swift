import UIKit

final class DoneButton: UIButton {
    
    var stateEnabled: Bool = true {
        didSet {
            if stateEnabled == false {
                layer.opacity = 0.3
                setImage(UIImage(named: "doneIcon"), for: .normal)
            } else {
                layer.opacity = 1
                setImage(UIImage(systemName: "plus"), for: .normal)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 17
        tintColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
