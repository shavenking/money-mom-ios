import UIKit

class QuickRecord {
    var amount: String?
    var tags: [String]?
    var audioRecording: String?

    init(amount: String, tags: [String], audioRecording: String) {
        self.amount = amount
        self.tags = tags
        self.audioRecording = audioRecording
    }
}
