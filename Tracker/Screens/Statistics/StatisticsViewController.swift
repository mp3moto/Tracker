import UIKit

final class StatisticsViewController: UIViewController {
    private let statisticsService: StatisticsService
    
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
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let bestPeriodView = StatisticsItemView()
    private let bestDaysView = StatisticsItemView()
    private let trackersCompletedView = StatisticsItemView()
    private let averageTrackersCompletedView = StatisticsItemView()
    
    private func placeholderIfNeeded() {
        if statisticsService.completedRecordsCount == 0 &&
            !noStatisticsView.isDescendant(of: view) {
            view.addSubview(noStatisticsView)
            NSLayoutConstraint.activate([
                noStatisticsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noStatisticsView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])
        } else {
            noStatisticsView.removeFromSuperview()
        }
    }
    
    init(statisticsService: StatisticsService) {
        self.statisticsService = statisticsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        
        view.addSubview(metricsView)
        metricsView.addSubview(bestPeriodView)
        metricsView.addSubview(bestDaysView)
        metricsView.addSubview(trackersCompletedView)
        metricsView.addSubview(averageTrackersCompletedView)
        
        bestPeriodView.metricDescription = "Лучший период"
        bestDaysView.metricDescription = "Идеальные дни"
        trackersCompletedView.metricDescription = "Трекеров завершено"
        averageTrackersCompletedView.metricDescription = "Среднее значение"
        
        bestPeriodView.value = "6"
        bestDaysView.value = "2"
        trackersCompletedView.value = "5"
        averageTrackersCompletedView.value = "4"
        
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
            averageTrackersCompletedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: statisticsItemHeightAnchorMultiplier),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsService.trackersCompleted()
        print(statisticsService.trackersCompletedAverage())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        placeholderIfNeeded()
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
}
