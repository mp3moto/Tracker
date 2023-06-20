import UIKit

final class OnboardingViewControllerPage: UIViewController {
    private var backgroundImage: String
    private var pageText: String
    private var buttonText: String
    private var viewModel: OnboardingViewModel?
    
    init(backgroundImage: String, pageText: String, buttonText: String) {
        self.backgroundImage = backgroundImage
        self.pageText = pageText
        self.buttonText = buttonText
        super.init(nibName: nil, bundle: nil)
    }
    
    func initialize(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onButtonTap = { returnedValue in
            if returnedValue {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("Can't access AppDelegate") }
                appDelegate.changeVC(viewController: TabBarViewController())
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc private func showHomeScreen() {
        viewModel?.buttonTapped()
    }
    
    private func setup() {
        let bgImage = UIImageView(image: UIImage(named: backgroundImage))
        let label = UILabel()
        let button = YPButton(text: buttonText, destructive: false)
        
        button.addTarget(self, action: #selector(showHomeScreen), for: .touchUpInside)
        
        label.text = pageText
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        label.textColor = UIColor(named: "YPBlack")
        label.numberOfLines = 2
        label.textAlignment = .center
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(bgImage)
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            bgImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImage.topAnchor.constraint(equalTo: view.topAnchor),
            bgImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 76),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 26),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
}
