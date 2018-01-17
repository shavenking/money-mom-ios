import UIKit

class AmountLabel: UILabel {
  static func large() -> AmountLabel {
    let amountLabel = AmountLabel()
    amountLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    return amountLabel
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    textColor = MMColor.white
    backgroundColor = MMColor.black
    textAlignment = .center
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
