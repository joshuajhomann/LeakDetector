//
//  LeakDetectorApp.swift
//  LeakDetector
//
//  Created by Joshua Homann on 6/2/23.
//

import SwiftUI

@main
struct LeakDetectorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showDebugMenu = false
    @State private var didAppear = false
    var body: some Scene {
        WindowGroup {
            if showDebugMenu {
                DebugView(shouldShow: $showDebugMenu)
            } else {
                ContentView()
                    .onAppear {
                        guard !didAppear else { return }
                        didAppear = true
                        appDelegate.onTapNotification = { notification in
                            switch notification.categoryIdentifier {
                            case "debug": showDebugMenu = true
                            default: break
                            }
                        }
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                            print(granted, String(describing: error))
                        }
                    }
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    var onTapNotification: (UNNotificationContent) -> Void = { _ in }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            onTapNotification(response.notification.request.content)
        }
    }
}
