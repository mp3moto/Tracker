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
    
    let iconPinned: UIImageView = {
        let view = UIImageView(image: UIImage(named: AppImages.iconPinned.rawValue))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let title: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = CGFloat(16)
        paragraphStyle.maximumLineHeight = CGFloat(16)
        label.attributedText = NSAttributedString(
            string: "",
            attributes: [
                .paragraphStyle : paragraphStyle
            ]
        )
        
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = .white
        label.numberOfLines = 2
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton = DoneButton()
    
    let doneLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = UIColor(named: "YPBlack")
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
        itemBackground.addSubview(iconView)
        itemBackground.addSubview(title)
        contentView.addSubview(doneButton)
        contentView.addSubview(doneLabel)
        
        NSLayoutConstraint.activate([
            itemBackground.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            itemBackground.heightAnchor.constraint(equalToConstant: 90),
            itemBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.topAnchor.constraint(equalTo: itemBackground.topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: itemBackground.leadingAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: itemBackground.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: itemBackground.trailingAnchor, constant: -12),
            title.bottomAnchor.constraint(equalTo: itemBackground.bottomAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: itemBackground.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: itemBackground.trailingAnchor, constant: -12),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneLabel.leadingAnchor.constraint(equalTo: itemBackground.leadingAnchor, constant: 12),
            doneLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPinnedIcon(_ show: Bool) {
        let isChild = iconPinned.isDescendant(of: itemBackground)
        if show && !isChild {
            itemBackground.addSubview(iconPinned)
            setupIconPinnedConstraints()
        } else if !show && isChild {
            iconPinned.removeFromSuperview()
        }
    }
    
    func setupIconPinnedConstraints() {
        NSLayoutConstraint.activate([
            iconPinned.topAnchor.constraint(equalTo: itemBackground.topAnchor, constant: 12),
            iconPinned.leadingAnchor.constraint(greaterThanOrEqualTo: itemBackground.leadingAnchor),
            iconPinned.trailingAnchor.constraint(equalTo: itemBackground.trailingAnchor, constant: -4)
        ])
    }
    
    func getContextMenuPreview() -> UIView {
        itemBackground
    }
}
