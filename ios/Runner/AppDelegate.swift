import Flutter
import UIKit
import GoogleMaps 
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyBDofFDgj0khESt0SuFqXR2c-B0JRQdlFU")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
