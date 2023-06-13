import UIKit

final class CategoryListCell: UITableViewCell {
    static let reuseIdentifier = "CategoryListCell"
    private var viewModel: CategoryViewModel?
    
    var cellViewModel: CategoryViewModel? {
        didSet {
            guard let cellViewModel = cellViewModel else { return }
            titleLabel.text = cellViewModel.name
            checkmarkImage.isHidden = !cellViewModel.selected
            configCell(first: cellViewModel.first, last: cellViewModel.last)
        }
    }
    
    private let containerView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }()
    
    private let checkmarkImage: UIImageView = {
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
        checkmarkImage.isHidden = true
        configCell(first: false, last: false)
    }
    
    func configCell(first: Bool, last: Bool) {
        backgroundColor = UIColor(named: "YPTextFieldBackground")

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
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
        
        layer.maskedCorners = []
        layer.cornerRadius = 0
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if first || last {
            layer.cornerRadius = 16
            if first && last {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
            } else if first {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
}
