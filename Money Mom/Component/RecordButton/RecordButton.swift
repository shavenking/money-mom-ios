import UIKit

protocol RecordButtonDelegate {
    func userWannaStartRecording()
    func userWannaStopRecording()
}

class RecordButton: UIButton {
    var delegate: RecordButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setDefaultStyle()

        layer.cornerRadius = 4
        layer.masksToBounds = true

        addTarget(self, action: #selector(startRecording), for: .touchDown)
        addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        addTarget(self, action: #selector(stopRecording), for: .touchUpOutside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDefaultStyle() {
        setTitle("按住我錄音", for: .normal)
        setTitleColor(MMColor.white, for: .normal)
        backgroundColor = MMColor.black
    }

    func setStyleForRecording() {
        setTitle("放開結束錄音", for: .normal)
        setTitleColor(MMColor.white, for: .normal)
        backgroundColor = MMColor.red
    }
}

extension RecordButton {
    @objc private func startRecording() {
        delegate?.userWannaStartRecording()
    }

    @objc private func stopRecording() {
        delegate?.userWannaStopRecording()
    }
}
