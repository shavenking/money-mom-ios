import UIKit

class ReadOnlyTagCollectionViewCell: TagCollectionViewCell {
    override func addSubviews() {
        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        label.lineBreakMode = .byTruncatingMiddle
    }
}
