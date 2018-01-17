import Foundation
import CoreData

@objc class TransactionType: NSObject, NSCoding {
  static let INCOME: TransactionType = TransactionType(rawValue: 0)
  static let EXPENSE: TransactionType = TransactionType(rawValue: 1)
  let rawValue: Int

  private init(rawValue: Int) {
    self.rawValue = rawValue
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(rawValue, forKey: "rawValue")
  }

  required init?(coder aDecoder: NSCoder) {
    self.rawValue = aDecoder.decodeInteger(forKey: "rawValue")
  }
}

extension TransactionType {
  static func == (lhs: TransactionType, rhs: TransactionType) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

@objc enum TransactionTypeEnum: Int16 {
  case INCOME = 0
  case EXPENSE = 1
  case UNKNOWN = 2
}

class Transaction: NSManagedObject {
  @NSManaged var amount: NSDecimalNumber
  @NSManaged var audioUUID: UUID?
  @NSManaged var date: Date
  @NSManaged var location: String?
  @NSManaged var tags: Set<Tag>
  @NSManaged var type: TransactionTypeEnum
  @objc var createdAtDay: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.timeZone = TimeZone.current
    return formatter.string(from: date)
  }
  override var hashValue: Int {
    return objectID.hashValue
  }
}
