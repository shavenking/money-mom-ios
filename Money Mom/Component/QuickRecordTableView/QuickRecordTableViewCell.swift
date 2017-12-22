import UIKit

class QuickRecordTableViewCell: UITableViewCell {
    let amountLabel = UILabel()
    let tagsLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(amountLabel)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        amountLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        amountLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        amountLabel.textColor = MMColor.black

        contentView.addSubview(tagsLabel)

        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor).isActive = true
        tagsLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        tagsLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        tagsLabel.textColor = MMColor.black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
