import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    lazy var quickRecordTableView: QuickRecordTableView = {
        var tableView = QuickRecordTableView()
        tableView.dataSource = self
        return tableView
    }()

    var quickRecords = [QuickRecord]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showQuickCreateViewController))

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
        let cell = (tableView as! QuickRecordTableView).dequeueReusableCell(for: indexPath)

        cell.amountLabel.text = "$" + (quickRecords[indexPath.row].amount ?? "")
        cell.tags = quickRecords[indexPath.row].tags ?? []

        if let audioUUID = quickRecords[indexPath.row].audioUUID, let audioFilePath = MMConfig.audioFilePath(of: audioUUID) {
            do {
                cell.player = try AVAudioPlayer(contentsOf: audioFilePath)
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
