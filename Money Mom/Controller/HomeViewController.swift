//import UIKit
//import AVFoundation
//import CoreData
//
//class HomeViewController: UIViewController {
//    override var title: String? {
//        get {
//            return super.title ?? "快速記帳"
//        }
//        set {
//            super.title = newValue
//        }
//    }
//
//    lazy var quickRecordTableView: QuickRecordTableView = {
//        var tableView = QuickRecordTableView()
//        tableView.dataSource = self
//        return tableView
//    }()
//
//    lazy var fetchedResultsController: NSFetchedResultsController<QuickRecord> = {
//        let request = NSFetchRequest<QuickRecord>(entityName: String(describing: QuickRecord.self))
//        request.predicate = NSPredicate(format: "\(#keyPath(QuickRecord.isProcessed)) = %@", argumentArray: [false])
//        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(QuickRecord.createdAt), ascending: false)]
//        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext
//        let fetchedResultsController = NSFetchedResultsController<QuickRecord>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = MMColor.white
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showQuickCreateViewController))
//
//        view.addSubview(quickRecordTableView)
//        quickRecordTableView.translatesAutoresizingMaskIntoConstraints = false
//        quickRecordTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        quickRecordTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        quickRecordTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
//        quickRecordTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
//        try! fetchedResultsController.performFetch()
//    }
//
//    @objc func showQuickCreateViewController() {
//    navigationController?.pushViewController(QuickCreateViewController(), animated: true)
//    }
//}
//
//extension HomeViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let quickRecords = fetchedResultsController.fetchedObjects else {
//            return 0
//        }
//
//        return quickRecords.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = (tableView as! QuickRecordTableView).dequeueReusableCell(for: indexPath)
//
//        cell.quickRecord = fetchedResultsController.object(at: indexPath)
//        cell.delegate = self
//
//        return cell
//    }
//}
//
//extension HomeViewController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        quickRecordTableView.reloadData()
//    }
//}
//
//extension HomeViewController: QuickRecordTableViewCellDelegate {
//    func userWannaEdit(quickRecord: QuickRecord) {
//        if let viewController = tabBarController?.viewControllers?.first(where: { controller in
//            return (controller as? UINavigationController)?.topViewController is UnderstandHowToCreateTransaction
//        }) {
//            tabBarController?.selectedViewController = viewController
//            ((viewController as! UINavigationController).topViewController as! UnderstandHowToCreateTransaction).userWannaCreateTransactionFrom(quickRecord: quickRecord)
//        }
//    }
//}
