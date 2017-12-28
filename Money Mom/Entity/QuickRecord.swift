import Foundation
import CoreData

public class QuickRecord: NSManagedObject {
    public class func fetchRequest() -> NSFetchRequest<QuickRecord> {
        return NSFetchRequest<QuickRecord>(entityName: "QuickRecord")
    }

    @NSManaged public var amount: String
    @NSManaged public var audioUUID: UUID
    @NSManaged public var id: UUID
    @NSManaged public var tags: Set<String>
    @NSManaged public var created_at: Date
}
