import UIKit

final class CategoryListCell: UITableViewCell {
    static let reuseIdentifier = "CategoryListCell"
    private var viewModel: CategoryViewModel?
    
    var cellText: String? {
        didSet {
            titleLabel.text = cellText
        }
    }
    
    var cellViewModel: CategoryViewModel? {
        didSet {
            cellText = cellViewModel?.name
            checkmarkImage.isHidden = !(cellViewModel?.selected ?? false)
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
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initiate(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.onChange = { [weak self] in
            self?.cellText = viewModel.name
        }
    }
    
    func configCell(number num: Int, of total: Int) {
        backgroundColor = UIColor(named: "YPGray")

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
        if num == 1 || num == total {
            layer.cornerRadius = 16
            if num == 1 && total == 1 {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
            } else {
                if num != total {
                    if num == 1 {
                        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                } else {
                    separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
                    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
            }
        }
    }
}
