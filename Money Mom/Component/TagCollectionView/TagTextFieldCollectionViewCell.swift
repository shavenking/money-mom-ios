import UIKit

protocol TagTextFieldDelegate {
    func didAdd(tag: String)
    func didChange(text: String)
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
        textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
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
}
