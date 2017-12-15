import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showQuickCreateViewController))
    }

    @objc func showQuickCreateViewController() {
        navigationController?.pushViewController(QuickCreateViewController(), animated: true)
    }
}
