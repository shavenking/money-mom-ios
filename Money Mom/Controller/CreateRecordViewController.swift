import UIKit
import AVFoundation
import CoreData

class CreateRecordViewController: QuickCreateViewController {
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
        amountTextField.text = quickRecord.amount
        tags = quickRecord.tags
        datePicker.setDate(quickRecord.created_at, animated: false)
        setDateTextFieldText(with: quickRecord.created_at)
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
        dump("save")
    }
}

extension CreateRecordViewController {
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

extension CreateRecordViewController {
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
