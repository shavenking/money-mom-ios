import Foundation
import AVFoundation

struct MMConfig {
    static let recordingDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    static func audioFileURL(of uuid: UUID) -> URL? {
        return recordingDirectory?.appendingPathComponent(uuid.uuidString)
    }

    static let recordingSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
}
