import UIKit

class PlayButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setTitleColor(MMColor.white, for: .normal)
        backgroundColor = MMColor.black

        setUnavailableToPlayStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAvailableToPlayStyle() {
        setTitle("▶", for: .normal)
        isUserInteractionEnabled = true
    }

    func setUnavailableToPlayStyle() {
        setTitle("-", for: .normal)
        isUserInteractionEnabled = false
    }
}
