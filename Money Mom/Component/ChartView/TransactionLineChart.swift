import UIKit

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter
}()

fileprivate extension Calendar {
    func dates(from: Date, to: Date) -> [Date] {
        var current: Date = from
        var dates = [Date]([from])

        while current <= to {
            dates.append(current)

            if let next = date(byAdding: .day, value: 1, to: current) {
                current = next
            }
        }

        return dates
    }
}

class TransactionLineChart: UIView {
    var transactions: [Transaction]? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = MMColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let innerRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        drawExpense(in: innerRect)
        drawIncome(in: innerRect)
        drawBorder(in: innerRect)
    }

    private func drawBorder(in rect: CGRect) {
        MMColor.black.setStroke()
        UIColor.clear.setFill()

        let border = UIBezierPath()

        border.lineWidth = 2
        border.lineCapStyle = .round
        border.lineJoinStyle = .round

        border.move(to: rect.origin)

        border.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        border.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        border.stroke()
    }

    private func drawExpense(in rect: CGRect) {
        guard let expenses = expenses(), let maxAmount = maxAmount(), let minDate = minDate(), let maxDate = maxDate() else {
            return
        }

        let dates = Calendar.current.dates(from: minDate, to: maxDate)
        let stepX = rect.width / CGFloat(dates.count)
        let stepY = NSDecimalNumber(value: Double(rect.height)).dividing(by: maxAmount)

        MMColor.red.setStroke()
        UIColor.clear.setFill()

        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round

        bezierPath.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        for (idx, date) in dates.enumerated() {
            let day = formatter.string(from: date)
            let x: CGFloat = stepX * CGFloat(idx)
            var y: CGFloat = 0
            if let transactionAtDate = expenses.first(where: { formatter.string(from: $0.date) == day }) {
                y = CGFloat(truncating: transactionAtDate.amount.multiplying(by: stepY))
            }

            bezierPath.addLine(to: CGPoint(x: x + rect.minX, y: rect.maxY - y))
        }

        bezierPath.stroke()
    }

    private func drawIncome(in rect: CGRect) {
        guard let incomes = incomes(), let maxAmount = maxAmount(), let minDate = minDate(), let maxDate = maxDate() else {
            return
        }

        let dates = Calendar.current.dates(from: minDate, to: maxDate)
        let stepX = rect.width / CGFloat(dates.count)
        let stepY = NSDecimalNumber(value: Double(rect.height)).dividing(by: maxAmount)

        MMColor.green.setStroke()
        UIColor.clear.setFill()

        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round

        bezierPath.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        for (idx, date) in dates.enumerated() {
            let day = formatter.string(from: date)
            let x = CGFloat(idx) * stepX
            var y: CGFloat = 0
            if let transactionAtDate = incomes.first(where: { formatter.string(from: $0.date) == day }) {
                y = CGFloat(truncating: transactionAtDate.amount.multiplying(by: stepY))
            }

            bezierPath.addLine(to: CGPoint(x: x + rect.minX, y: rect.maxY - y))
        }

        bezierPath.stroke()
    }

    private func transactionsWithoutNAN() -> [Transaction]? {
        return transactions?.filter {
            $0.amount != .notANumber
        }
    }

    private func expenses() -> [Transaction]? {
        return transactionsWithoutNAN()?.filter {
            $0.type == .EXPENSE
        }
    }

    private func incomes() -> [Transaction]? {
        return transactionsWithoutNAN()?.filter {
            $0.type == .INCOME
        }
    }

    private func maxAmount() -> NSDecimalNumber? {
        return transactions?.max {
            $0.amount.compare($1.amount) == .orderedAscending
        }?.amount
    }

    private func maxDate() -> Date? {
        return Date()
    }

    private func minDate() -> Date? {
        return transactions?.min {
            $0.date <= $1.date
        }?.date
    }
}
