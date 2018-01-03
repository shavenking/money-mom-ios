import UIKit

class CreateRecordViewController: UIViewController {
    var quickRecord: QuickRecord?

    convenience init(quickRecord: QuickRecord) {
        self.init()

        self.quickRecord = quickRecord
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        dump(quickRecord)
    }
}
