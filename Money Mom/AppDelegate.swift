import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var persistentContainer: NSPersistentContainer?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let appearance = UINavigationBar.appearance()
    appearance.barTintColor = MMColor.blue
    appearance.tintColor = MMColor.black
    window = UIWindow(frame: UIScreen.main.bounds)
    let transactionViewController = UINavigationController(rootViewController: TransactionViewController())
    transactionViewController.tabBarItem = UITabBarItem(title: "收支記錄",
                                                        image: UIImage(named: "dollar-black"),
                                                        selectedImage: UIImage(named: "dollar-black"))
    let statsViewController = UINavigationController(rootViewController: StatsViewController())
    statsViewController.tabBarItem = UITabBarItem(title: "統計圖表",
                                                  image: UIImage(named: "pie-chart-black"),
                                                  selectedImage: UIImage(named: "pie-chart-black"))
    let rootViewController = UITabBarController()
    rootViewController.tabBar.tintColor = MMColor.blue
    rootViewController.viewControllers = [transactionViewController, statsViewController]
    window?.rootViewController = rootViewController
    window?.makeKeyAndVisible()
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores { _, error in
      guard error == nil else {
        fatalError("Failed to load store: Model")
      }
      self.persistentContainer = container
    }
    return true
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    dump(userActivity.activityType)
    dump(userActivity.webpageURL)
    return false
  }
}
