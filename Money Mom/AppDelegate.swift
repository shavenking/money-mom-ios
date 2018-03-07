import UIKit
import CoreData
import UserNotifications

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

    registerForPushNotifications()

    return true
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    dump(userActivity.activityType)
    dump(userActivity.webpageURL)
    return false
  }

  func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    dump(url)
    return true
  }

  func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      print("Permission granted: \(granted)")

      guard granted else { return }

      let viewAction = UNNotificationAction(identifier: "News", title: "This is title", options: [.foreground])

      let newsCategory = UNNotificationCategory(identifier: "NewsCategory", actions: [viewAction], intentIdentifiers: [])

      UNUserNotificationCenter.current().setNotificationCategories([newsCategory])

      self.getNotificationSettings()
    }
  }

  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }

    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register: \(error)")
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    dump(userInfo)
  }
}
