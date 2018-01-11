import Foundation
import CoreData

@objc class TransactionStats: NSManagedObject, Taggable {
    func fetchRequest() -> NSFetchRequest<TransactionStats> {
        return NSFetchRequest<TransactionStats>(entityName: "TransactionStats")
    }

    @NSManaged var date: Date
    @NSManaged var amount: NSDecimalNumber
    @NSManaged var type: TransactionType
    @NSManaged var tags: Set<Tag>
}
