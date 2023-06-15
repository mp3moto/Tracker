import UIKit

final class StatisticsItemView: UIView {
    var value: String? {
        get {
            return valueLabel.text
        }
        set {
            valueLabel.text = newValue
        }
    }
    
    var metricDescription: String? {
        get {
            return metricDescriptionLabel.text
        }
        set {
            metricDescriptionLabel.text = newValue
        }
    }
    
    private let valueLabelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let metricDescriptionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Bold", size: 34)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metricDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(valueLabelView)
        valueLabelView.addSubview(valueLabel)
        addSubview(metricDescriptionView)
        metricDescriptionView.addSubview(metricDescriptionLabel)
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        gradient.locations = [0, 0.5, 1.0]
        gradient.colors = [
            UIColor(red: 0.992, green: 0.298, blue: 0.286, alpha: 1).cgColor,
            UIColor(red: 0.274, green: 0.902, blue: 0.615, alpha: 1).cgColor,
            UIColor(red: 0.0, green: 0.482, blue: 0.98, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.masksToBounds = true
        gradient.cornerRadius = 16
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "YPBlack")?.cgColor
        layer.addSublayer(gradient)
        
        layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            valueLabelView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabelView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            valueLabelView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.45),
            
            valueLabel.centerYAnchor.constraint(equalTo: valueLabelView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: valueLabelView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: valueLabelView.trailingAnchor),
            
            metricDescriptionView.topAnchor.constraint(equalTo: valueLabelView.bottomAnchor, constant: 7),
            metricDescriptionView.leadingAnchor.constraint(equalTo: valueLabelView.leadingAnchor),
            metricDescriptionView.trailingAnchor.constraint(equalTo: valueLabelView.trailingAnchor),
            metricDescriptionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            metricDescriptionLabel.centerYAnchor.constraint(equalTo: metricDescriptionView.centerYAnchor),
            metricDescriptionLabel.leadingAnchor.constraint(equalTo: metricDescriptionView.leadingAnchor),
            metricDescriptionLabel.trailingAnchor.constraint(equalTo: metricDescriptionView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
