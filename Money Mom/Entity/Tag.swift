import Foundation
import CoreData

class Tag: NSManagedObject, Comparable {
    @NSManaged var name: String
    @NSManaged var transactions: Set<Transaction>
    @NSManaged var quickRecords: Set<QuickRecord>
    @NSManaged var transactionStatsSet: Set<TransactionStats>

    override var hashValue: Int {
        return name.hashValue
    }

    static func <(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name < rhs.name
    }
}
