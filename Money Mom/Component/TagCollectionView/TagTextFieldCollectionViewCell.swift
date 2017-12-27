import UIKit

@objc protocol TagTextFieldDelegate {
    func didAdd(tag: String)
    func didChange(text: String)
    @objc optional func didEndEditing()
}

class TagTextFieldCollectionViewCell: UICollectionViewCell {
    lazy var textField: UITextField = {
        let label = UILabel()
        label.text = "標籤："
        label.sizeToFit()
        label.textColor = MMColor.black

        var textField = UITextField()
        textField.leftView = label
        textField.leftViewMode = .always
        textField.delegate = self
        textField.textColor = MMColor.black
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    var delegate: TagTextFieldDelegate?

    var text: String? {
        didSet {
            textField.text = text
            textField.sizeToFit()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textField: textField)

        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubview(textField: UITextField) {
        contentView.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }
}

extension TagTextFieldCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        delegate?.didAdd(tag: text.trimmingCharacters(in: .whitespacesAndNewlines))

        textField.text = ""
        delegate?.didChange(text: "")

        return true
    }

    @objc func textFieldDidChange() {
        delegate?.didChange(text: textField.text ?? "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didEndEditing?()
    }
}
