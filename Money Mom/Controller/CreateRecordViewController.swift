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

        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.topAnchor.constraint(equalTo: recordButton.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        dateTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
