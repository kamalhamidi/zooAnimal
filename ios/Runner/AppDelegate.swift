import Flutter
import UIKit
import GoogleMobileAds
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    configureAdMob()
    return result
  }

  private func configureAdMob() {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { _ in
        DispatchQueue.main.async {
          GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
      }
    } else {
      GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
