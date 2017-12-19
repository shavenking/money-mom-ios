import UIKit

protocol TagCollectionViewCellDelegate {
    func didTouchButton(in tag: TagCollectionViewCell)
}

class TagCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    let button: UIButton = {
        var button = UIButton()
        button.setTitle("⤫", for: .normal)
        button.setTitleColor(MMColor.red, for: .normal)
        button.sizeToFit()
        return button
    }()

    var delegate: TagCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
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
