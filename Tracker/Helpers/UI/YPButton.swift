import UIKit

final class YPButton: UIButton {
    
    init(text: String, destructive: Bool) {
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "YPBlack")
        setTitle(text, for: .normal)
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        setTitleColor(UIColor(named: "White Color"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
