import UIKit

class MoneyMomView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = MMColor.white
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    let innerRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    let path = UIBezierPath()
    path.lineWidth = 20
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.move(to: CGPoint(x: innerRect.width / 4 + innerRect.minX, y: innerRect.maxY))
    path.addLine(to: CGPoint(x: innerRect.width / 4 + innerRect.minX, y: innerRect.minY))
    path.addLine(to: CGPoint(x: innerRect.width / 2 + innerRect.minX, y: innerRect.maxY))
    path.addLine(to: CGPoint(x: innerRect.width * 3 / 4 + innerRect.minX, y: innerRect.minY))
    path.addLine(to: CGPoint(x: innerRect.width * 3 / 4 + innerRect.minX, y: innerRect.maxY))
    path.stroke()
  }
}
