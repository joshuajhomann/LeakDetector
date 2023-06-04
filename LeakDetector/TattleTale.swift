//
//  TattleTale.swift
//  LeakDetector
//
//  Created by Joshua Homann on 6/4/23.
//

import Foundation
import NotificationCenter
import OSLog

actor TattleTale {
    static let shared = TattleTale()
    private init() { }
    private(set) var tracked = [String: Int]()
    private let leakLogger = Logger(subsystem: "com.josh.example", category: "leaks")
    func register(_ name: String) async {
        tracked[name, default: 0] += 1
        let value = tracked[name]
        if let value, value > 1 {
            let content = UNMutableNotificationContent()
            content.title = "Leak detected!!!"
            content.body = "\(name) count:\(value)"
            content.categoryIdentifier = "debug"
            content.sound = UNNotificationSound.defaultCritical
            leakLogger.debug("Leak detected: \(name) count:\(value)")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            try! await UNUserNotificationCenter.current().add(request)
        }
    }
    func unregister(_ name: String) {
        tracked[name, default: 0] -= 1
        if let value = tracked[name], value < 1 {
            tracked.removeValue(forKey: name)
        }
    }
}
