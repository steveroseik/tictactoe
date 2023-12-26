//import UIKit
//import Flutter
//import FBSDKCoreKit
//
//@UIApplicationMain
//@objc class AppDelegate: FlutterAppDelegate {
//    
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Register Flutter plugins
//        GeneratedPluginRegistrant.register(with: self)
//
//        // Initialize Facebook SDK
//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    // Handle open URL for Facebook Login
//    override func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
//    ) -> Bool {
//        return ApplicationDelegate.shared.application(
//            app,
//            open: url,
//            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }
//
//}


import UIKit
import Flutter
import FBSDKCoreKit
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
