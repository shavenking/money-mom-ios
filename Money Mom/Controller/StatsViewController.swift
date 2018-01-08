import UIKit

class StatsViewController: UIViewController {
    override var title: String? {
        get {
            return super.title ?? "統計圖表"
        }
        set {
            super.title = newValue
        }
    }

    let mmView = MoneyMomView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        view.addSubview(mmView)

        mmView.translatesAutoresizingMaskIntoConstraints = false

        mmView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mmView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        mmView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        mmView.heightAnchor.constraint(equalTo: mmView.widthAnchor).isActive = true
    }
}
