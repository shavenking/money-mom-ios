import UIKit
import CoreData

class StatsViewController: UIViewController {
    override var title: String? {
        get {
            return super.title ?? "統計圖表"
        }
        set {
            super.title = newValue
        }
    }

    let transactionLineChart = TransactionLineChart()

    lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        let request = NSFetchRequest<Transaction>(entityName: String(describing: Transaction.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.createdAt), ascending: false)]
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext
        let fetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: #keyPath(Transaction.createdAtDay), cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        view.addSubview(transactionLineChart)

        transactionLineChart.translatesAutoresizingMaskIntoConstraints = false

        transactionLineChart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transactionLineChart.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10).isActive = true

        transactionLineChart.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        transactionLineChart.heightAnchor.constraint(equalTo: transactionLineChart.widthAnchor, multiplier: 0.5).isActive = true

        try! fetchedResultsController.performFetch()

//        transactionLineChart.transactions = fetchedResultsController.fetchedObjects
    }
}

extension StatsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        transactionLineChart.transactions = controller.fetchedObjects as? [Transaction]
    }
}
