//
//  ContentView.swift
//  AlgoTrade
//
//  Created by fung on 11/7/2021.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Startup procedure
    // firebase start -> notification manager start -> USER start
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var USER: DBUSER = DBUSER()
    @State var startupFinished = false
    @State var selectedTab = 0
    let FIRPublisher = FirebasePublisher.shared.publisher
    
    var body: some View {
        TabView(selection: $selectedTab){
            HomeTabView(startupFinished: $startupFinished)
                .tabItem({
                    Image(systemName: "house")
                    Text("Home")
                }).tag(0)
            MoreTabView(startupFinished: $startupFinished)
                .tabItem({
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }).tag(1)
        }
        .onAppear(perform: {
            FirebaseService.shared.start { value in
                //NotificationManager.shared.start()
                delegate.start()
                startup()
            }
        })
        .onReceive(FIRPublisher) { value in
            debugPrint("received fir publisher")
            //if startupFinished {
                if value{}//local change
                else{//server change
                    USER.getFireLatest { result in
                        if result == "SUCCESS" {}
                        else {}
                    }
                }
            //}
        }
        .environmentObject(USER)
    }
    func startup(){
        USER.start {value in
            if value == "SUCCESS"{
                startupFinished = true
            }
            else {
                startupFinished = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
