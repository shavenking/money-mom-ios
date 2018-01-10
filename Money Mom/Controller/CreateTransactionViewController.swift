import UIKit
import AVFoundation
import CoreData

class CreateTransactionViewController: QuickCreateViewController {
    var quickRecord: QuickRecord? {
        didSet {
            if let quickRecord = quickRecord {
                updateUI(with: quickRecord)
            }
        }
    }

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()

    lazy var dateTextField: UITextField = {
        let dateTextField = UITextField()
        dateTextField.inputView = datePicker
        dateTextField.textColor = MMColor.black
        dateTextField.leftViewMode = .always
        dateTextField.leftView = {
            let leftViewLabel = UILabel()
            leftViewLabel.text = "日期："
            leftViewLabel.sizeToFit()
            leftViewLabel.textColor = MMColor.black
            return leftViewLabel
        }()
        return dateTextField
    }()

    lazy var locationTextField: UITextField = {
        let locationTextField = UITextField()
        locationTextField.textColor = MMColor.black
        locationTextField.leftViewMode = .always
        locationTextField.leftView = {
            let leftViewLabel = UILabel()
            leftViewLabel.text = "地點："
            leftViewLabel.sizeToFit()
            leftViewLabel.textColor = MMColor.black
            return leftViewLabel
        }()
        return locationTextField
    }()

    let transactionTypeLabel: UILabel = {
        let transactionTypeLabel = UILabel()
        transactionTypeLabel.text = "分類："
        transactionTypeLabel.textColor = MMColor.black
        transactionTypeLabel.sizeToFit()
        return transactionTypeLabel
    }()

    lazy var transactionTypeSegmentedControl: UISegmentedControl = {
        let transactionTypeSegmentedControl = UISegmentedControl()
        transactionTypeSegmentedControl.tintColor = MMColor.black
        transactionTypeSegmentedControl.insertSegment(withTitle: "收入", at: 0, animated: false)
        transactionTypeSegmentedControl.insertSegment(withTitle: "支出", at: 1, animated: false)
        transactionTypeSegmentedControl.addTarget(self, action: #selector(transactionTypeChanged), for: .valueChanged)

        return transactionTypeSegmentedControl
    }()

    convenience init(quickRecord: QuickRecord) {
        self.init()

        self.quickRecord = quickRecord
        updateUI(with: quickRecord)
    }

    private func updateUI(with quickRecord: QuickRecord) {
        amountTextField.text = quickRecord.amount.stringValue
        tags = quickRecord.tags
        datePicker.setDate(quickRecord.createdAt, animated: false)
        setDateTextFieldText(with: quickRecord.createdAt)
        tagCollectionView.reloadData()
    }

    override func addSubviews() {
        super.addSubviews()

        view.addSubview(dateTextField)
        view.addSubview(locationTextField)
        view.addSubview(transactionTypeSegmentedControl)
        view.addSubview(transactionTypeLabel)

        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.topAnchor.constraint(equalTo: recordButton.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        dateTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        locationTextField.translatesAutoresizingMaskIntoConstraints = false
        locationTextField.topAnchor.constraint(equalTo: dateTextField.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        locationTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        locationTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        locationTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        transactionTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionTypeLabel.topAnchor.constraint(equalTo: locationTextField.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        transactionTypeLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        transactionTypeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        transactionTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        transactionTypeSegmentedControl.topAnchor.constraint(equalTo: locationTextField.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        transactionTypeSegmentedControl.leftAnchor.constraint(equalTo: transactionTypeLabel.rightAnchor).isActive = true
        transactionTypeSegmentedControl.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        transactionTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    override func save() {
        guard let quickRecord = quickRecord else {
            return
        }

        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext

        guard let transaction = NSEntityDescription.insertNewObject(forEntityName: String(describing: Transaction.self), into: viewContext) as? Transaction else {
            fatalError("Insert Transaction Failed")
        }

        quickRecord.isProcessed = true
        quickRecord.transaction = transaction

        transaction.amount = quickRecord.amount
        transaction.audioUUID = audioUUID
        transaction.createdAt = datePicker.date
        transaction.id = UUID()
        transaction.location = locationTextField.text ?? ""
        transaction.tags = quickRecord.tags

        if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
            transaction.type = TransactionType.INCOME
        } else {
            transaction.type = TransactionType.EXPENSE
        }
        transaction.quickRecord = quickRecord

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let midnight = calendar.startOfDay(for: transaction.createdAt)
        let request = NSFetchRequest<TransactionStats>(entityName: String(describing: TransactionStats.self))
        request.predicate = NSPredicate(format: "\(#keyPath(TransactionStats.date)) = %@", argumentArray: [midnight])
        guard let transactionStat = try! viewContext.fetch(request).first(where: {
            return $0.type == transaction.type
        }) else {
            let transactionStat = NSEntityDescription.insertNewObject(forEntityName: String(describing: TransactionStats.self), into: viewContext) as! TransactionStats

            transactionStat.amount = transaction.amount
            transactionStat.date = midnight
            transactionStat.type = transaction.type

            try! viewContext.save()
            navigationController?.popToRootViewController(animated: true)

            return
        }

        transactionStat.amount = transactionStat.amount.adding(transaction.amount)
        try! viewContext.save()

        navigationController?.popToRootViewController(animated: true)
    }
}

extension CreateTransactionViewController {
    @objc func datePickerValueChanged() {
        setDateTextFieldText(with: datePicker.date)
    }

    private func setDateTextFieldText(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        dateTextField.text = formatter.string(from: date)
    }
}

extension CreateTransactionViewController {
    @objc func transactionTypeChanged() {
        if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
            transactionTypeSegmentedControl.tintColor = MMColor.green
            transactionTypeSegmentedControl.setTitleTextAttributes([
                NSAttributedStringKey.foregroundColor: MMColor.black
            ], for: .normal)
            transactionTypeSegmentedControl.setTitleTextAttributes([
                NSAttributedStringKey.foregroundColor: MMColor.black
            ], for: .selected)
        } else {
            transactionTypeSegmentedControl.tintColor = MMColor.red
            transactionTypeSegmentedControl.setTitleTextAttributes([
                NSAttributedStringKey.foregroundColor: MMColor.black
            ], for: .normal)
            transactionTypeSegmentedControl.setTitleTextAttributes([
                NSAttributedStringKey.foregroundColor: MMColor.white
            ], for: .selected)
        }
    }
}

extension CreateTransactionViewController: UnderstandHowToCreateTransaction {
    func userWannaCreateTransactionFrom(quickRecord: QuickRecord) {
        self.quickRecord = quickRecord
    }
}
