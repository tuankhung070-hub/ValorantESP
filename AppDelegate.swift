import UIKit
import ReplayKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var overlayWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        overlayWindow = UIWindow(frame: UIScreen.main.bounds)
        overlayWindow?.windowLevel = .statusBar + 1
        overlayWindow?.rootViewController = OverlayViewController()
        overlayWindow?.isHidden = false
        overlayWindow?.backgroundColor = .clear
        overlayWindow?.makeKeyAndVisible()
        
        CaptureManager.shared.startCapture()
        return true
    }
}
