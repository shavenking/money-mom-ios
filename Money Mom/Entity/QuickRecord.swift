import UIKit

class QuickRecord {
    var amount: String?
    var tags: [String]?
    var audioUUID: UUID?

    init(amount: String, tags: [String], audioUUID: UUID) {
        self.amount = amount
        self.tags = tags
        self.audioUUID = audioUUID
    }
}
