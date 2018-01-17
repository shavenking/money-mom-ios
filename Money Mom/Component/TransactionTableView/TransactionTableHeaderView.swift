import UIKit

class TransactionTableHeaderView: UITableViewHeaderFooterView {
  let totalIncomeLabel: UILabel = {
    let label = UILabel()
    label.textColor = MMColor.white
    return label
  }()
  let totalExpenseLabel: UILabel = {
    let label = UILabel()
    label.textColor = MMColor.white
    return label
  }()
  let dayLabel: UILabel = {
    let label = UILabel()
    label.textColor = MMColor.white
    label.font = .preferredFont(forTextStyle: .largeTitle)
    return label
  }()
  let monthYearLabel: UILabel = {
    let label = UILabel()
    label.textColor = MMColor.white
    return label
  }()
  var totalIncome = NSDecimalNumber.zero {
    didSet {
      totalIncomeLabel.text = "收入 \(totalIncome)"
    }
  }
  var totalExpense = NSDecimalNumber.zero {
    didSet {
      totalExpenseLabel.text = "支出 \(totalExpense)"
    }
  }
  var date = Date() {
    didSet {
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: date)
      if let day = components.day {
        dayLabel.text = String(describing: day)
        dayLabel.sizeToFit()
      }
      if let month = components.month, let year = components.year {
        monthYearLabel.text = "/ \(month) / \(year)"
        monthYearLabel.sizeToFit()
      }
    }
  }

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = MMColor.black
    contentView.addSubview(dayLabel)
    contentView.addSubview(monthYearLabel)
    contentView.addSubview(totalIncomeLabel)
    contentView.addSubview(totalExpenseLabel)
    dayLabel.translatesAutoresizingMaskIntoConstraints = false
    dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    dayLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
    monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
    monthYearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    monthYearLabel.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: 5).isActive = true
    totalIncomeLabel.translatesAutoresizingMaskIntoConstraints = false
    totalIncomeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    totalIncomeLabel.leftAnchor.constraint(greaterThanOrEqualTo: monthYearLabel.rightAnchor).isActive = true
    totalIncomeLabel.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor,
                                            multiplier: 1 / 4).isActive = true
    totalExpenseLabel.translatesAutoresizingMaskIntoConstraints = false
    totalExpenseLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    totalExpenseLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
    totalExpenseLabel.leftAnchor.constraint(equalTo: totalIncomeLabel.rightAnchor).isActive = true
    totalExpenseLabel.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor,
                                             multiplier: 1 / 4).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
