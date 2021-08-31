//
//  AppDelegate.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getDeliveredNotifications { list in
            PreferenceService.shared.set_badge_count(count: list.count)
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = list.count
            }
        }
        UIScrollView.appearance().keyboardDismissMode = .interactive
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint(deviceToken)
        debugPrint("registered with device token above")
        var tokenString = ""
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        tokenString = token
        PreferenceService.shared.setDeviceToken(hexString: tokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("error hetting remote notifications'")
        debugPrint(error)
    }
    
    // app receive remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func start(){
        debugPrint("request")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
            if error != nil {
                debugPrint(error as Any)
            }
            else {
                debugPrint("register")
                DispatchQueue.main.async {
                    debugPrint(UIApplication.shared.isRegisteredForRemoteNotifications)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint(notification.request.content.userInfo)
        debugPrint(notification.request.identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        completionHandler([.banner,.sound, .list])
    }
    
    // background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        debugPrint(userInfo)
        debugPrint(response.notification.request.identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        completionHandler()
    }
}
