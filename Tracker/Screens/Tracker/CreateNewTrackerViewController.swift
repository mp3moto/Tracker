import UIKit

final class CreateNewTrackerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        let titleView = UILabel()
        titleView.text = "Создание трекера"
        titleView.font = UIFont(name: "YSDisplay-Medium", size: 16)
        titleView.textColor = UIColor(named: "YPBlack")
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let menuView = UIView(frame: .zero)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        let newHabitButton = YPButton(text: "Привычка", destructive: false)
        let newEventButton = YPButton(text: "Нерегулярное событие", destructive: false)
        
        newHabitButton.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
        newEventButton.addTarget(self, action: #selector(addNewEvent), for: .touchUpInside)
        
        menuView.addSubview(newHabitButton)
        menuView.addSubview(newEventButton)
        
        view.addSubview(menuView)
        
        NSLayoutConstraint.activate([
            newHabitButton.heightAnchor.constraint(equalToConstant: 60),
            newHabitButton.topAnchor.constraint(equalTo: menuView.topAnchor),
            newHabitButton.widthAnchor.constraint(equalTo: menuView.widthAnchor),
            newEventButton.heightAnchor.constraint(equalToConstant: 60),
            newEventButton.topAnchor.constraint(equalTo: newHabitButton.bottomAnchor, constant: 16),
            newEventButton.widthAnchor.constraint(equalTo: menuView.widthAnchor),
            
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            menuView.heightAnchor.constraint(equalToConstant: 136)
        ])
        
        //let menuViewHeight = menuView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        //
    }
    
    @objc func addNewHabit() {
        let newHabitVC = NewTrackerViewController()
        present(newHabitVC, animated: true)
    }
    
    @objc func addNewEvent() {
        print("addNewEvent called")
    }
}
