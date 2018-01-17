import Foundation
import CoreData

final class StringAmountToDecimalAmountPolicy: NSEntityMigrationPolicy {
  override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                           in mapping: NSEntityMapping,
                                           manager: NSMigrationManager) throws {
    let dInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!,
                                                        into: manager.destinationContext)
    dInstance.setValue(sInstance.value(forKey: "id"), forKey: "id")
    dInstance.setValue(NSDecimalNumber(string: sInstance.value(forKey: "amount") as? String), forKey: "amount")
    dInstance.setValue(sInstance.value(forKey: "audioUUID"), forKey: "audioUUID")
    dInstance.setValue(sInstance.value(forKey: "created_at"), forKey: "createdAt")
    dInstance.setValue(sInstance.value(forKey: "tags"), forKey: "tags")
    dInstance.setValue(false, forKey: "isProcessed")
    dInstance.setValue(nil, forKey: "transaction")
    manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
  }
}
