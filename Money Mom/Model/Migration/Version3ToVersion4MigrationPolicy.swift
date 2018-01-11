import UIKit
import CoreData

class Version3ToVersion4MigrationPolicy: NSEntityMigrationPolicy {
    let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        switch mapping.name {
        case "Tag":
            return
        case "TransactionStats":
            let sTransactionStats = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first!

            let dateRange = [
                calendar.startOfDay(for: sTransactionStats.value(forKey: "date") as! Date),
                calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: sTransactionStats.value(forKey: "date") as! Date)!)
            ]

            let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: Transaction.self))
            request.predicate = NSPredicate(format: "\(#keyPath(Transaction.createdAt)) >= %@ AND \(#keyPath(Transaction.createdAt)) < %@", argumentArray: dateRange)

            let sTransactions = try! manager.sourceContext.fetch(request)

            var tagNames = Set<String>()

            sTransactions.forEach { transaction in
                tagNames = tagNames.union(transaction.value(forKey: "tags") as! Set<String>)
            }

            var tags = Set<NSManagedObject>()

            tagNames.forEach { tagName in
                tags.insert(createDestinationTag(named: tagName, manager: manager))
            }

            dInstance.setValue(tags, forKey: "tags")
        case "Transaction":
            let sTransaction = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first!

            let tagNames = sTransaction.value(forKey: "tags") as! Set<String>

            var tags = Set<NSManagedObject>()

            tagNames.forEach { tagName in
                tags.insert(createDestinationTag(named: tagName, manager: manager))
            }

            dInstance.setValue(tags, forKey: "tags")

            guard let sQuickRecord = sTransaction.value(forKey: "quickRecord") else {
                return
            }

            let dQuickRecord = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sQuickRecord as! NSManagedObject]).first

            dInstance.setValue(dQuickRecord, forKey: "quickRecord")
        case "QuickRecord":
            let sInstance = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first!

            let tagNames = sInstance.value(forKey: "tags") as! Set<String>

            var tags = Set<NSManagedObject>()

            tagNames.forEach { tagName in
                tags.insert(createDestinationTag(named: tagName, manager: manager))
            }

            dInstance.setValue(tags, forKey: "tags")

            guard let sInstanceRelationship = sInstance.value(forKey: "transaction") else {
                return
            }

            let dInstanceRelationship = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstanceRelationship as! NSManagedObject]).first

            dInstance.setValue(dInstanceRelationship, forKey: "transaction")
        default:
            fatalError()
        }
    }

    private func createDestinationTag(named tagName: String, manager: NSMigrationManager) -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: Tag.self))
        request.predicate = NSPredicate(format: "\(#keyPath(Tag.name)) = %@", argumentArray: [tagName])

        let tags = try! manager.destinationContext.fetch(request)

        if tags.isEmpty {
            let tag = NSEntityDescription.insertNewObject(forEntityName: String(describing: Tag.self), into: manager.destinationContext)
            tag.setValue(tagName, forKey: "name")

            return tag
        }

        return tags.first!
    }
}
