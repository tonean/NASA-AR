import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create the main window
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set ViewController as the root view controller
        window.rootViewController = ViewController() // Your AR ViewController
        self.window = window
        
        // Display the window
        window.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Handle when the app is about to go inactive
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle app entering background
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle app entering foreground
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart tasks that were paused when the app was inactive
    }
}
