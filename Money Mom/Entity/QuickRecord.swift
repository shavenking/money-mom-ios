import Foundation
import CoreData

class QuickRecord: QuickRecordBase {
    func fetchRequest() -> NSFetchRequest<QuickRecord> {
        return NSFetchRequest<QuickRecord>(entityName: "QuickRecord")
    }

    @NSManaged var isProcessed: Bool
    @NSManaged var transaction: Transaction?
}
