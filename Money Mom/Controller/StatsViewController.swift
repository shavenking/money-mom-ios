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

    lazy var tagCollectionView: TagCollectionView = {
        var tagCollectionView = TagCollectionView.horizontalLayout()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.allowsMultipleSelection = true

        return tagCollectionView
    }()

    var selectedTags = Set<Tag>() {
        didSet {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "ANY \(#keyPath(TransactionStats.tags)) IN %@", argumentArray: [selectedTags])
            try! fetchedResultsController.performFetch()
            transactionLineChart.transactionStatsSet = fetchedResultsController.fetchedObjects
        }
    }

    lazy var fetchedResultsController: NSFetchedResultsController<TransactionStats> = {
        let request = NSFetchRequest<TransactionStats>(entityName: String(describing: TransactionStats.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TransactionStats.date), ascending: false)]
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext
        let fetchedResultsController = NSFetchedResultsController<TransactionStats>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    lazy var tagFetchedResultsController: NSFetchedResultsController<Tag> = {
        let request = NSFetchRequest<Tag>(entityName: String(describing: Tag.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: false)]
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext
        let fetchedResultsController = NSFetchedResultsController<Tag>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        view.addSubview(transactionLineChart)
        view.addSubview(tagCollectionView)

        transactionLineChart.translatesAutoresizingMaskIntoConstraints = false
        transactionLineChart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transactionLineChart.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        transactionLineChart.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        transactionLineChart.heightAnchor.constraint(equalTo: transactionLineChart.widthAnchor, multiplier: 0.5).isActive = true

        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tagCollectionView.topAnchor.constraint(equalTo: transactionLineChart.bottomAnchor, constant: 10).isActive = true
        tagCollectionView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        tagCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        try! fetchedResultsController.performFetch()
        try! tagFetchedResultsController.performFetch()

        transactionLineChart.transactionStatsSet = fetchedResultsController.fetchedObjects
        tagCollectionView.reloadData()
    }
}

extension StatsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.fetchRequest.entityName == String(describing: TransactionStats.self) {
            transactionLineChart.transactionStatsSet = fetchedResultsController.fetchedObjects
        }

        if controller.fetchRequest.entityName == String(describing: Tag.self) {
            tagCollectionView.reloadData()
        }
    }
}

extension StatsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagFetchedResultsController.fetchedObjects?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView as! TagCollectionView).dequeueReusableCell(forReadOnlyTagAt: indexPath)

        guard let tag = tagFetchedResultsController.fetchedObjects?.sorted()[indexPath.row] else {
            return cell
        }

        cell.tagData = tag
        cell.setGray()

        if selectedTags.contains(tag) {
            cell.setSelected()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = ReadOnlyTagCollectionViewCell()
        cell.tagData = tagFetchedResultsController.fetchedObjects?.sorted()[indexPath.row]

        return CGSize(width: min(cell.label.frame.width + cell.layoutMargins.right + cell.layoutMargins.left, tagCollectionView.frame.width / 2), height: 50);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else {
            return
        }

        cell.setSelected()

        if let tag = cell.tagData {
            selectedTags.insert(tag)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else {
            return
        }

        cell.deselect()

        if let tag = cell.tagData {
            selectedTags.remove(tag)
        }
    }
}
