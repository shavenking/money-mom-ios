import Foundation
import CoreData

final class TransactionStatsPolicy: NSEntityMigrationPolicy {
  let calendar: Calendar = {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }()

  // swiftlint:disable force_cast force_try
  override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                           in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    let midnight = calendar.startOfDay(for: sInstance.value(forKey: "createdAt") as! Date)
    let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
    request.predicate = NSPredicate(format: "date = %@", argumentArray: [midnight])
    guard let transactionStat = try! manager.destinationContext.fetch(request).first(where: {
      return $0.value(forKey: "type") as! TransactionType == sInstance.value(forKey: "type") as! TransactionType
    }) else {
      let dInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!,
                                                          into: manager.destinationContext)
      dInstance.setValue(sInstance.value(forKey: "amount"), forKey: "amount")
      dInstance.setValue(midnight, forKey: "date")
      dInstance.setValue(sInstance.value(forKey: "type"), forKey: "type")
      return
    }
    transactionStat.setValue((sInstance.value(forKey: "amount") as! NSDecimalNumber)
                               .adding(transactionStat.value(forKey: "amount") as! NSDecimalNumber),
                             forKey: "amount")
  }
}
