import UIKit

final class ScheduleListCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleListCell"
    
    var cellText: String? {
        didSet {
            titleLabel.text = cellText
        }
    }
    
    let containerView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }()
    
    let tumbler: UISwitch = {
        let tumbler = UISwitch()
        tumbler.translatesAutoresizingMaskIntoConstraints = false
        return tumbler
    }()
    
    let titleLabel: UILabel = {
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
        
        backgroundColor = UIColor(named: "YPGray")
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(tumbler)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            tumbler.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tumbler.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
