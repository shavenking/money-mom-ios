import Foundation
import CoreData

class Version4ToVersion5MigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        switch mapping.name {
        case "Tag":
            let dInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
            dInstance.setValue(sInstance.value(forKey: "name"), forKey: "name")

            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        case "Transaction":
            let dInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
            dInstance.setValue(sInstance.value(forKey: "amount"), forKey: "amount")
            if FileManager.default.fileExists(atPath: MMConfig.audioFilePath(of: sInstance.value(forKey: "audioUUID") as! UUID)!.path) {
                dInstance.setValue(sInstance.value(forKey: "audioUUID"), forKey: "audioUUID")
            }
            dInstance.setValue(sInstance.value(forKey: "createdAt"), forKey: "date")
            dInstance.setValue(sInstance.value(forKey: "location"), forKey: "location")
            dInstance.setValue((sInstance.value(forKey: "type") as! TransactionType).rawValue, forKey: "type")

            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        case "QuickRecord":
            guard (sInstance.value(forKey: "isProcessed") as! Bool) == false else {
                return
            }

            let dInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
            dInstance.setValue(sInstance.value(forKey: "amount"), forKey: "amount")
            if FileManager.default.fileExists(atPath: MMConfig.audioFilePath(of: sInstance.value(forKey: "audioUUID") as! UUID)!.path) {
                dInstance.setValue(sInstance.value(forKey: "audioUUID"), forKey: "audioUUID")
            }
            dInstance.setValue(sInstance.value(forKey: "createdAt"), forKey: "date")
            dInstance.setValue(2, forKey: "type")

            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        default:
            fatalError()
        }
    }

    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard mapping.name == "Transaction" || mapping.name == "QuickRecord" else {
            return
        }

        let sInstance = manager.sourceInstances(forEntityMappingName: manager.sourceEntity(for: mapping)!.name!, destinationInstances: [dInstance]).first!

        let sTags = Array(sInstance.value(forKey: "tags") as! Set<NSManagedObject>)
        let dTags = Set(manager.destinationInstances(forEntityMappingName: "Tag", sourceInstances: sTags))

        dInstance.setValue(dTags, forKey: "tags")
    }
}
