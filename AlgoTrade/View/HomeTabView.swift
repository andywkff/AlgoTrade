//
//  HomeTabView.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import SwiftUI

struct HomeTabView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Binding var startupFinished: Bool
    //@State var selectionIndex: Int = -1
    @State var isPresent: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                DefaultView()//selectionIndex: $selectionIndex
            }
            .navigationBarColor(backgroundColor: UIColor(named: "NavBarColor")!, tintColor: .white)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction){
                    Button {
                        isPresent.toggle()
                    } label: {
                        Image(systemName: "doc.badge.plus")
                            .font(.headline)
                    }
                }
            })
            .sheet(isPresented: $isPresent, content: {
                NewInstrumentView(isPresent: $isPresent)
                    .environmentObject(USER)
            })
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView(startupFinished: .constant(true))
    }
}
