import UIKit

class QuickRecordTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        estimatedRowHeight = 160
        rowHeight = 160
        separatorStyle = .none
        allowsSelection = false
        register(QuickRecordTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(QuickRecordTableViewCell.self))
    }

    func dequeueReusableCell(for indexPath: IndexPath) -> QuickRecordTableViewCell {
        return super.dequeueReusableCell(withIdentifier: NSStringFromClass(QuickRecordTableViewCell.self), for: indexPath) as! QuickRecordTableViewCell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
