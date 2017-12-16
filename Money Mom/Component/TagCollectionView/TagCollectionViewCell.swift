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

        let margin = contentView.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    }
}
