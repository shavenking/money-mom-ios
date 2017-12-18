import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    lazy var label: UILabel = {
        return UILabel()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label: label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubview(label: UILabel) {
        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true

        label.lineBreakMode = .byTruncatingMiddle
    }
}
