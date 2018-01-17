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
  let incomeTotalLabel: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    label.backgroundColor = MMColor.green
    label.textColor = MMColor.black
    label.textAlignment = .center
    label.text = "0"
    return label
  }()
  let expenseTotalLabel: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    label.backgroundColor = MMColor.red
    label.textColor = MMColor.white
    label.textAlignment = .center
    label.text = "0"
    return label
  }()
  lazy var tagCollectionView: TagCollectionView = {
    var tagCollectionView = TagCollectionView()
    tagCollectionView.dataSource = self
    tagCollectionView.delegate = self
    tagCollectionView.allowsMultipleSelection = true
    return tagCollectionView
  }()
  var selectedTags = Set<Tag>() {
    didSet {
      if selectedTags.isEmpty {
        transactionFetchedResultsController.fetchRequest.predicate = nil
      } else {
        // swiftlint:disable line_length
        transactionFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "ANY \(#keyPath(Transaction.tags)) IN %@", argumentArray: [selectedTags])
        // swiftlint:enable line_length
      }
      do {
        try transactionFetchedResultsController.performFetch()
      } catch {
        fatalError(error.localizedDescription)
      }
      transactionLineChart.transactions = transactionFetchedResultsController.fetchedObjects
      calculateTotal()
    }
  }
  @objc lazy var transactionFetchedResultsController: NSFetchedResultsController<Transaction> = {
    guard let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext else {
      fatalError("failed to get ViewContext from AppDelegate")
    }
    let request = NSFetchRequest<Transaction>(entityName: String(describing: Transaction.self))
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.date), ascending: false)]
    let fetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request,
                                                                           managedObjectContext: viewContext,
                                                                           sectionNameKeyPath: nil,
                                                                           cacheName: nil)
    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  lazy var tagFetchedResultsController: NSFetchedResultsController<Tag> = {
    guard let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext else {
      fatalError("failed to get ViewContext from AppDelegate")
    }
    let request = NSFetchRequest<Tag>(entityName: String(describing: Tag.self))
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: false)]
    let fetchedResultsController = NSFetchedResultsController<Tag>(fetchRequest: request,
                                                                   managedObjectContext: viewContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MMColor.white
    view.addSubview(transactionLineChart)
    view.addSubview(tagCollectionView)
    view.addSubview(incomeTotalLabel)
    view.addSubview(expenseTotalLabel)
    transactionLineChart.translatesAutoresizingMaskIntoConstraints = false
    transactionLineChart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    transactionLineChart.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
    transactionLineChart.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
    transactionLineChart.heightAnchor.constraint(equalTo: transactionLineChart.widthAnchor,
                                                 multiplier: 0.5).isActive = true
    incomeTotalLabel.translatesAutoresizingMaskIntoConstraints = false
    incomeTotalLabel.topAnchor.constraint(equalTo: transactionLineChart.bottomAnchor, constant: 8).isActive = true
    incomeTotalLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    incomeTotalLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor,
                                            constant: -4).isActive = true
    incomeTotalLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    expenseTotalLabel.translatesAutoresizingMaskIntoConstraints = false
    expenseTotalLabel.topAnchor.constraint(equalTo: transactionLineChart.bottomAnchor, constant: 8).isActive = true
    expenseTotalLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 4).isActive = true
    expenseTotalLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    expenseTotalLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
    tagCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    tagCollectionView.topAnchor.constraint(equalTo: incomeTotalLabel.bottomAnchor, constant: 8).isActive = true
    tagCollectionView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
    tagCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor,
                                              constant: -8).isActive = true
    do {
      try transactionFetchedResultsController.performFetch()
      try tagFetchedResultsController.performFetch()
    } catch {
      fatalError("failed to perform fetch in StatsViewController")
    }
    transactionLineChart.transactions = transactionFetchedResultsController.fetchedObjects
    tagCollectionView.reloadData()
    calculateTotal()
  }

  private func calculateTotal() {
    var incomeTotal: NSDecimalNumber = .zero
    var expenseTotal: NSDecimalNumber = .zero
    transactionFetchedResultsController.fetchedObjects?.forEach { transaction in
      if transaction.type == .INCOME {
        incomeTotal = incomeTotal.adding(transaction.amount)
      } else if transaction.type == .EXPENSE {
        expenseTotal = expenseTotal.adding(transaction.amount)
      }
    }
    incomeTotalLabel.text = incomeTotal.stringValue
    expenseTotalLabel.text = expenseTotal.stringValue
  }
}

extension StatsViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller.fetchRequest.entityName == String(describing: Transaction.self) {
      transactionLineChart.transactions = transactionFetchedResultsController.fetchedObjects
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
    guard let cell = (collectionView as? TagCollectionView)?.dequeueReusableCell(forReadOnlyTagAt: indexPath) else {
      fatalError("failed to dequeue readonly cell from TagCollectionView in StatsViewController")
    }
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

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cell = ReadOnlyTagCollectionViewCell()
    cell.tagData = tagFetchedResultsController.fetchedObjects?.sorted()[indexPath.row]
    return CGSize(width: min(cell.label.frame.width + cell.layoutMargins.right + cell.layoutMargins.left,
                             tagCollectionView.frame.width / 2),
                  height: 50)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
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
