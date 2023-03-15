import UIKit

final class CategoryListCell: UITableViewCell {
    static let reuseIdentifier = "CategoryListCell"
    
    var cellText: String? {
        didSet {
            titleLabel.text = cellText
        }
    }
    
    private let containerView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }()
    
    let checkmarkImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "checkmark"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(named: "YPGray")
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        checkmarkImage.isHidden = true
        containerView.addSubview(checkmarkImage)
        
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            checkmarkImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            checkmarkImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
