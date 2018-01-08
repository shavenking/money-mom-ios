import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var persistentContainer: NSPersistentContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = MMColor.blue
        appearance.tintColor = MMColor.black

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = UITabBarController()
        rootViewController.viewControllers = [
            UINavigationController(rootViewController: HomeViewController()),
            UINavigationController(rootViewController: TransactionHomeViewController()),
            UINavigationController(rootViewController: StatsViewController())
        ]
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("Failed to load store: Model")
            }

            self.persistentContainer = container
        }

        return true
    }
}

