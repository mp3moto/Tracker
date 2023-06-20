import UIKit

final class YPButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor(named: "YPBlack") : UIColor(named: "YPDisabled")
            let textColor = isEnabled ? "YPButtonText" : "YPWhite"
            setTitleColor(UIColor(named: textColor), for: .normal)
        }
    }
    
    init(text: String, destructive: Bool) {
        super.init(frame: .zero)
        setTitle(text, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        if (!destructive) {
            backgroundColor = UIColor(named: "YPBlack")
            setTitleColor(UIColor(named: "YPButtonText"), for: .normal)
        } else {
            backgroundColor = UIColor.systemBackground
            setTitleColor(UIColor(named: "YPRed"), for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "YPRed")?.cgColor
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
