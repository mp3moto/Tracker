import UIKit

final class TrackerListItem: UICollectionViewCell {
    static let reuseIdentifier = "trackerListItem"
    let itemBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let icon: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Bold", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(cgColor: CGColor(red: 255, green: 255, blue: 255, alpha: 0.3))
            view.layer.cornerRadius = 12
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(icon)
            
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 24),
                view.heightAnchor.constraint(equalToConstant: 24),
                icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
            
            return view
        }()
        
        contentView.addSubview(itemBackground)
        contentView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            itemBackground.widthAnchor.constraint(equalToConstant: 167),
            itemBackground.heightAnchor.constraint(equalToConstant: 90),
            itemBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.topAnchor.constraint(equalTo: itemBackground.topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: itemBackground.leadingAnchor, constant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
