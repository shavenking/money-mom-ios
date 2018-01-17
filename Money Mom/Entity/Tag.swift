import Foundation
import CoreData

class Tag: NSManagedObject, Comparable {
  @NSManaged var name: String
  @NSManaged var transactions: Set<Transaction>
  override var hashValue: Int {
    return name.hashValue
  }

  static func < (lhs: Tag, rhs: Tag) -> Bool {
    return lhs.name < rhs.name
  }
}
