import UIKit

class AmountTextField: UITextField {
    override init(frame: CGRect) {
       super.init(frame: frame)

        let label = UILabel()
        label.text = "金額："
        label.sizeToFit()
        label.textColor = MMColor.black

        leftView = label
        leftViewMode = .always
        textColor = MMColor.black
        backgroundColor = MMColor.white
        keyboardType = .decimalPad
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
