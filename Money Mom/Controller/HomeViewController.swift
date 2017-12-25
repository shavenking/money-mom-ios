import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    let quickRecordTableView = UITableView()

    var quickRecords = [QuickRecord]()

    let documentDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showQuickCreateViewController))

        quickRecordTableView.dataSource = self
        quickRecordTableView.rowHeight = 160
        quickRecordTableView.separatorStyle = .none
        quickRecordTableView.allowsSelection = false
        quickRecordTableView.register(QuickRecordTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(QuickRecordTableViewCell.self))

        view.addSubview(quickRecordTableView)
        quickRecordTableView.translatesAutoresizingMaskIntoConstraints = false
        quickRecordTableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        quickRecordTableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        quickRecordTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        quickRecordTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    @objc func showQuickCreateViewController() {
        let VC = QuickCreateViewController()
        VC.delegate = self

        navigationController?.pushViewController(VC, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(QuickRecordTableViewCell.self), for: indexPath) as! QuickRecordTableViewCell

        cell.amountLabel.text = "$" + (quickRecords[indexPath.row].amount ?? "")
        cell.tags = quickRecords[indexPath.row].tags ?? []

        if let documentDirectory = documentDirectory, let audioRecording = quickRecords[indexPath.row].audioRecording {
            do {
                cell.player = try AVAudioPlayer(contentsOf: documentDirectory.appendingPathComponent(audioRecording))
            } catch {
                cell.player = nil
            }
        }

        return cell
    }
}

extension HomeViewController: QuickRecordDelegate {
    func didAdd(quickRecord: QuickRecord) {
        quickRecords.append(quickRecord)
        quickRecordTableView.reloadData()
    }
}
