import UIKit

final class EmojiCell: UICollectionViewCell {
    var symbol: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        return label
    }()
    static let identifier = "Emoji"
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        
        contentView.addSubview(symbol)
        symbol.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            symbol.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            symbol.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
