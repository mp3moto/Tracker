import UIKit

final class TestScreen: UIViewController {
    let tableRows: [String] = ["строка 1", "строка 2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TrackerListCell.self, forCellReuseIdentifier: TrackerListCell.reuseIdentifier)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}

extension TestScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerListCell.reuseIdentifier, for: indexPath) as? TrackerListCell else { return UITableViewCell() }
        
        cell.cellText = tableRows[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
