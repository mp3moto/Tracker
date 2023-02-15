import UIKit

final class ScheduleViewCotroller: UIViewController {
    let scheduleTableView = UITableView()
    let daysOfWeek: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var days: [Bool] = [false, false, false, false, false, false, false]
    weak var parentVC: NewTrackerViewController?
    var schedule: Schedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        if let schedule = schedule {
            days = convert(schedule: schedule)
        }
        
        /* -------------------------- TITLE -------------------------- */
        let titleView = UIView(frame: .zero)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 63)
        ])
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Расписание"
            label.font = UIFont(name: "YSDisplay-Medium", size: 16)
            label.textColor = UIColor(named: "YPBlack")
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 27)
        ])
        /*----------------------------------------------------------------*/
        
        /* ---------------------------- Button -------------------------- */
        let addCategoryButton = YPButton(text: "Готово", destructive: false)
        addCategoryButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            addCategoryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        /* --------------------------------------------------------------- */
        
        /* -------------------------- TableView -------------------------- */
        
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleTableView.register(ScheduleListCell.self, forCellReuseIdentifier: ScheduleListCell.reuseIdentifier)
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        
        view.addSubview(scheduleTableView)
        
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24),
            scheduleTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            scheduleTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            scheduleTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        /* --------------------------------------------------------------- */
    }
    
    func convert(schedule: Schedule) -> [Bool] {
        return [schedule.mon, schedule.tue, schedule.wed, schedule.thu, schedule.fri, schedule.sat, schedule.sun]
    }
    
    @objc func addSchedule() {
        parentVC?.selectedSchedule = Schedule(
            mon: days[0],
            tue: days[1],
            wed: days[2],
            thu: days[3],
            fri: days[4],
            sat: days[5],
            sun: days[6]
        )
        dismiss(animated: true)
    }
    
    @objc func tumblerChanged(_ sender: UISwitch) {
        days[sender.tag] = sender.isOn
    }
}

extension ScheduleViewCotroller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleListCell.reuseIdentifier, for: indexPath) as? ScheduleListCell else { return ScheduleListCell() }
        cell.cellText = daysOfWeek[indexPath.row]
        cell.layer.maskedCorners = []
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == daysOfWeek.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.tumbler.tag = indexPath.row
        cell.tumbler.isOn = days[indexPath.row]
        cell.tumbler.addTarget(self, action: #selector(tumblerChanged), for: .valueChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
