import UIKit

class ReadOnlyTagCollectionViewCell: UICollectionViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.textColor = MMColor.white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()

        layer.cornerRadius = 4
        layer.masksToBounds = true

        backgroundColor = MMColor.blue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        label.lineBreakMode = .byTruncatingMiddle
    }
}
