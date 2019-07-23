import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let flutterVC = self.window.rootViewController as! FlutterViewController
    /*
     IMPORTANT: The drop-in UI requires the use of a navigation controller to anchor the view controller. Please make sure the app has an active navigation controller which is passed to the navigationController parameter.
     */
    let navigation = UINavigationController.init(rootViewController: flutterVC)
    self.window.rootViewController = navigation
    self.window.makeKeyAndVisible()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
