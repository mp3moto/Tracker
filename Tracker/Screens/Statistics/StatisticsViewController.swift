import UIKit

final class StatisticsViewController: UIViewController {
    private let viewModel: StatisticsViewModel
    
    private let noStatisticsView: UIView = {
        let noTrackersIndicatorView = UIView()
        let noTrackersIndicatorImage = UIImageView(image: UIImage(named: "noStatistics"))
        let noTrackersIndicatorLabel = UILabel()
        noTrackersIndicatorLabel.text = LocalizedString.nothingToAnalyze
        noTrackersIndicatorLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        
        noTrackersIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
        noTrackersIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noTrackersIndicatorView.addSubview(noTrackersIndicatorImage)
        noTrackersIndicatorView.addSubview(noTrackersIndicatorLabel)
        
        let noTrackersIndicatorImageWidth = 80.0
        let noTrackersIndicatorImageHeight = 80.0
        let spaceBetweenImageAndLabel = 8.0
        let noTrackersIndicatorLabelHeight = noTrackersIndicatorLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let totalHeight = noTrackersIndicatorImageHeight + spaceBetweenImageAndLabel + noTrackersIndicatorLabelHeight
        
        NSLayoutConstraint.activate([
            noTrackersIndicatorImage.centerXAnchor.constraint(equalTo: noTrackersIndicatorView.centerXAnchor),
            noTrackersIndicatorImage.topAnchor.constraint(equalTo: noTrackersIndicatorView.topAnchor),
            noTrackersIndicatorImage.heightAnchor.constraint(equalToConstant: noTrackersIndicatorImageHeight),
            noTrackersIndicatorImage.widthAnchor.constraint(equalToConstant: noTrackersIndicatorImageWidth),
            noTrackersIndicatorLabel.topAnchor.constraint(equalTo: noTrackersIndicatorImage.bottomAnchor, constant: spaceBetweenImageAndLabel),
            noTrackersIndicatorLabel.centerXAnchor.constraint(equalTo: noTrackersIndicatorImage.centerXAnchor),
            noTrackersIndicatorView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        return noTrackersIndicatorView
    }()
    private let metricsView: UIView = {
        let view = UIView(frame: .zero)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let bestPeriodView = StatisticsItemView()
    private let bestDaysView = StatisticsItemView()
    private let trackersCompletedView = StatisticsItemView()
    private let averageTrackersCompletedView = StatisticsItemView()
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureNavigationBar()
        
        bestPeriodView.metricDescription = LocalizedString.statisticsBestPeriod
        bestDaysView.metricDescription = LocalizedString.statisticsBestDays
        averageTrackersCompletedView.metricDescription = LocalizedString.statisticsAverage
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getStatistic()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureNavigationBar() {
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        title = LocalizedString.statistics
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.font: UIFont(name: "YSDisplay-Bold", size: 34) ?? "System"]
        navigationItem.standardAppearance = appearance
    }
    
    private func setupUI() {
        if viewModel.trackersCompleted > 0 {
            view.addSubview(metricsView)
            metricsView.addSubview(bestPeriodView)
            metricsView.addSubview(bestDaysView)
            metricsView.addSubview(trackersCompletedView)
            metricsView.addSubview(averageTrackersCompletedView)
            setupConstraintsAndGradients()
        } else if metricsView.isDescendant(of: view) {
            metricsView.removeFromSuperview()
        }
        
    }
    
    private func setupConstraintsAndGradients() {
        let statisticsItemHeightAnchorMultiplier = 0.1236

        NSLayoutConstraint.activate([
            metricsView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            metricsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            metricsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            metricsView.bottomAnchor.constraint(equalTo: averageTrackersCompletedView.bottomAnchor),
            
            bestPeriodView.topAnchor.constraint(equalTo: metricsView.topAnchor),
            bestPeriodView.leadingAnchor.constraint(equalTo: metricsView.leadingAnchor),
            bestPeriodView.trailingAnchor.constraint(equalTo: metricsView.trailingAnchor),
            bestPeriodView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: statisticsItemHeightAnchorMultiplier),
            
            bestDaysView.topAnchor.constraint(equalTo: bestPeriodView.bottomAnchor, constant: 12),
            bestDaysView.leadingAnchor.constraint(equalTo: metricsView.leadingAnchor),
            bestDaysView.trailingAnchor.constraint(equalTo: metricsView.trailingAnchor),
            bestDaysView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: statisticsItemHeightAnchorMultiplier),
            
            trackersCompletedView.topAnchor.constraint(equalTo: bestDaysView.bottomAnchor, constant: 12),
            trackersCompletedView.leadingAnchor.constraint(equalTo: metricsView.leadingAnchor),
            trackersCompletedView.trailingAnchor.constraint(equalTo: metricsView.trailingAnchor),
            trackersCompletedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: statisticsItemHeightAnchorMultiplier),
            
            averageTrackersCompletedView.topAnchor.constraint(equalTo: trackersCompletedView.bottomAnchor, constant: 12),
            averageTrackersCompletedView.leadingAnchor.constraint(equalTo: trackersCompletedView.leadingAnchor),
            averageTrackersCompletedView.trailingAnchor.constraint(equalTo: trackersCompletedView.trailingAnchor),
            averageTrackersCompletedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: statisticsItemHeightAnchorMultiplier)
        ])
        
        view.layoutIfNeeded()
        
        metricsView.subviews.forEach {
            addBorderGradient(to: $0)
        }
    }
    
    func bind() {
        viewModel.onStatisticsRefreshed = { [weak self] in
            guard let self = self else { return }
            self.refreshStatisticsViews(
                trackersCompleted: self.viewModel.trackersCompleted,
                trackersAverage: self.viewModel.trackersAverage
            )
        }
    }
    
    private func placeholderIfNeeded() {
        if viewModel.trackersCompleted == 0 {
            view.addSubview(noStatisticsView)
            NSLayoutConstraint.activate([
                noStatisticsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noStatisticsView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])
        } else if noStatisticsView.isDescendant(of: view) {
            noStatisticsView.removeFromSuperview()
        }
    }
    
    func refreshStatisticsViews(trackersCompleted: Int, trackersAverage: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.trackersCompletedView.value = "\(trackersCompleted)"
            self.trackersCompletedView.metricDescription = String.localizedStringWithFormat(NSLocalizedString("trackersCompleted", comment: ""), trackersCompleted)
            self.averageTrackersCompletedView.value = String(format: "%.1f", trackersAverage)
            
            self.setupUI()
            self.placeholderIfNeeded()
        }
    }
    
    func addBorderGradient(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.5, 1.0]
        gradient.colors = [
            UIColor(red: 0.992, green: 0.298, blue: 0.286, alpha: 1).cgColor,
            UIColor(red: 0.274, green: 0.902, blue: 0.615, alpha: 1).cgColor,
            UIColor(red: 0.0, green: 0.482, blue: 0.98, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.masksToBounds = true
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        view.layer.addSublayer(gradient)
    }
}
