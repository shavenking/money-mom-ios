import Foundation
import CoreData

class QuickRecordBase: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var amount: NSDecimalNumber
    @NSManaged var audioUUID: UUID
    @NSManaged var createdAt: Date
    @NSManaged var tags: Set<String>
}
