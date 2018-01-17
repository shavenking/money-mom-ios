import UIKit

protocol TagCollectionViewCellDelegate: class {
  func didTouchButton(in cell: TagCollectionViewCell)
}

class TagCollectionViewCell: UICollectionViewCell {
  let label: UILabel = {
    let label = UILabel()
    label.textColor = MMColor.black
    return label
  }()
  let button: UIButton = {
    var button = UIButton()
    button.setTitle("⤫", for: .normal)
    button.setTitleColor(MMColor.red, for: .normal)
    button.sizeToFit()
    return button
  }()
  weak var delegate: TagCollectionViewCellDelegate?
  var tagData: Tag? {
    didSet {
      if let tagData = self.tagData {
        label.text = tagData.name
        label.sizeToFit()
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubviews()
    layer.cornerRadius = 4
    layer.masksToBounds = true
    backgroundColor = MMColor.black.withAlphaComponent(0.1)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    backgroundColor = MMColor.black.withAlphaComponent(0.1)
    label.textColor = MMColor.black
  }

  internal func addSubviews() {
    contentView.addSubview(label)
    contentView.addSubview(button)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
    label.trailingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true
    label.lineBreakMode = .byTruncatingMiddle
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
  }

  @objc private func didTouchButton() {
    delegate?.didTouchButton(in: self)
  }
}

extension TagCollectionViewCell {
  func setGray() {
    backgroundColor = MMColor.black.withAlphaComponent(0.1)
    label.textColor = MMColor.black
  }

  func setSelected() {
    backgroundColor = MMColor.blue
    label.textColor = MMColor.white
  }

  func deselect() {
    setGray()
  }
}
