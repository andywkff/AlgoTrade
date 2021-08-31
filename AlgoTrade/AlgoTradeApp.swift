//
//  AlgoTradeApp.swift
//  AlgoTrade
//
//  Created by fung on 11/7/2021.
//

import SwiftUI

@main
struct AlgoTradeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase, perform: {newScenePhase in
                    switch newScenePhase{
                    case .active:
                        UNUserNotificationCenter.current().getDeliveredNotifications { list in
                            PreferenceService.shared.set_badge_count(count: list.count)
                            DispatchQueue.main.async {
                                UIApplication.shared.applicationIconBadgeNumber = list.count
                            }
                        }
                    case .background:
                        return
                    case .inactive:
                        return
                    default:
                        return
                    }
                })
        }
    }
}
