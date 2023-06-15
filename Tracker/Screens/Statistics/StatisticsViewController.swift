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
