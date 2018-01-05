import UIKit

class TransactionTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        estimatedRowHeight = 160
        rowHeight = 160
        separatorStyle = .none
        allowsSelection = false
        register(TransactionTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TransactionTableViewCell.self))
    }

    func dequeueReusableCell(for indexPath: IndexPath) -> TransactionTableViewCell {
        return super.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionTableViewCell.self), for: indexPath) as! TransactionTableViewCell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
