import UIKit

protocol TagTextFieldDelegate {
    func didAdd(tag: String)
}

class TagTextFieldCollectionViewCell: UICollectionViewCell {
    lazy var textField: UITextField = {
        var textField = UITextField()
        textField.delegate = self
        return textField
    }()

    var delegate: TagTextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textField: textField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubview(textField: UITextField) {
        contentView.addSubview(textField)

        let margin = contentView.layoutMarginsGuide

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    }
}

extension TagTextFieldCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        delegate?.didAdd(tag: text.trimmingCharacters(in: .whitespacesAndNewlines))

        textField.text = ""

        return true
    }
}
