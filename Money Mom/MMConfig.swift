import Foundation

struct MMConfig {
    static let recordingDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    static func audioFilePath(of uuid: UUID) -> URL? {
        return recordingDirectory?.appendingPathComponent(uuid.uuidString)
    }
}
