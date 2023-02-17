import UIKit

final class TrackerListCell: UITableViewCell {
    static let reuseIdentifier = "TrackerListCell"
    
    var cellText: String? {
        didSet {
            titleLabel.text = cellText
        }
    }
    
    var cellValueText: String? {
        didSet {
            selectedValueLabel.text = cellValueText
        }
    }
    
    private let containerView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      //view.clipsToBounds = true
      return view
    }()
    
    private let chevronImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "chevron.right"))
        return image
    }()
    
    private let cellTextArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectedValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textColor = UIColor(named: "YPCellSelectedValue")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(named: "YPGray")
        
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(cellTextArea)
        cellTextArea.addSubview(titleLabel)
        cellTextArea.addSubview(selectedValueLabel)
        containerView.addSubview(chevronImage)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            cellTextArea.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cellTextArea.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cellTextArea.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cellTextArea.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            cellTextArea.bottomAnchor.constraint(equalTo: selectedValueLabel.bottomAnchor),
            //cellTextArea.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: cellTextArea.leadingAnchor),
            //titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            selectedValueLabel.leadingAnchor.constraint(equalTo: cellTextArea.leadingAnchor),
            selectedValueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            chevronImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chevronImage.centerYAnchor.constraint(equalTo: cellTextArea.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 24),
            chevronImage.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
