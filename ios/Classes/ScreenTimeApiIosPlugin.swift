import Flutter
import UIKit
import FamilyControls
import SwiftUI

public class ScreenTimeApiIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screen_time_api_ios", binaryMessenger: registrar.messenger())
        let instance = ScreenTimeApiIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "selectAppsToDiscourage":
            Task {
                // スクリーンタイムAPIの認証
                try await FamilyControlModel.shared.authorize()
                showController()
            }
            result(nil)
        case "encourageAll":
            // 全部解放する
            FamilyControlModel.shared.encourageAll();
            FamilyControlModel.shared.saveSelection(selection: FamilyActivitySelection())
            result(nil)
        case "getBlockedApps":
            let blockedApps = FamilyControlModel.shared.selectionToDiscourage.applications.map { $0.bundleIdentifier }
            result(blockedApps)
        case "getBlockedCategories":
            let blockedCategories = FamilyControlModel.shared.selectionToDiscourage.categories.map { $0.rawValue }
            result(blockedCategories)
        case "blockAppsAtTime":
            guard
                let args = call.arguments as? [String: Any],
                let bundleIds = args["bundleIds"] as? [String],
                let timestamp = args["timestamp"] as? TimeInterval
            else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                return
            }

            let fireDate = Date(timeIntervalSince1970: timestamp)
            let timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(blockApps(timer:)), userInfo: bundleIds, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            result(nil)
        case "unblockApp":
            guard let args = call.arguments as? [String: Any],
                      let bundleId = args["bundleId"] as? String
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                    return
                }

                var selection = FamilyControlModel.shared.selectionToDiscourage
                selection.applicationTokens.remove(ApplicationToken(bundleIdentifier: bundleId))
                FamilyControlModel.shared.selectionToDiscourage = selection
                result(nil)
        case "unblockAppAtTime":
            guard
                    let args = call.arguments as? [String: Any],
                    let bundleId = args["bundleId"] as? String,
                    let timestamp = args["timestamp"] as? TimeInterval
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                    return
                }

                let fireDate = Date(timeIntervalSince1970: timestamp)
                let timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(unblockApp(timer:)), userInfo: bundleId, repeats: false)
                RunLoop.main.add(timer, forMode: .common)
                result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc func onPressClose(){
        dismiss()
    }

    @objc private func blockApps(timer: Timer) {
        guard let bundleIds = timer.userInfo as? [String] else { return }

        var selection = FamilyControlModel.shared.selectionToDiscourage
        for bundleId in bundleIds {
            selection.applicationTokens.insert(ApplicationToken(bundleIdentifier: bundleId))
        }
        FamilyControlModel.shared.selectionToDiscourage = selection
    }

    @objc private func unblockApp(timer: Timer) {
        if let bundleId = timer.userInfo as? String {
            var selection = FamilyControlModel.shared.selectionToDiscourage
            selection.applicationTokens.remove(ApplicationToken(bundleIdentifier: bundleId))
            FamilyControlModel.shared.selectionToDiscourage = selection
        }
    }
    
    func showController() {
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let windows = windowScene?.windows
            let controller = windows?.filter({ (w) -> Bool in
                return w.isHidden == false
            }).first?.rootViewController as? FlutterViewController
            
            // アプリ選択のUIを出す
            let selectAppVC: UIViewController = UIHostingController(rootView: ContentView())
            selectAppVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(self.onPressClose)
            )
            let naviVC = UINavigationController(rootViewController: selectAppVC)
            controller?.present(naviVC, animated: true, completion: nil)
        }
    }
    
    func dismiss(){
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let windows = windowScene?.windows
            let controller = windows?.filter({ (w) -> Bool in
                return w.isHidden == false
            }).first?.rootViewController as? FlutterViewController
            controller?.dismiss(animated: true, completion: nil)
        }
    }
}
