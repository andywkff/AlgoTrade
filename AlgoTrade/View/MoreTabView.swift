//
//  MoreTabView.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import SwiftUI

struct MoreTabView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Binding var startupFinished: Bool
    @State var isPresent: Bool = false
    
    var body: some View {
        NavigationView{
            List{
                Section(header: Text("General")) {
                    Button(action: {isPresent.toggle()}, label: {
                        Text("Edit Instrument")
                    })
                }
                Section(header: Text("Beware")) {
                    NavigationLink(destination:
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack{
                                Button(action: { forceSync() }, label: {
                                    Text("Force Simulate All")
                                })
                                .buttonStyle(FilledButton())
                            }
                            .frame(maxWidth: .infinity,alignment: .center)
                            .padding()
                            .navigationBarTitle("Force Simulate")
                        }).frame(maxWidth: .infinity,alignment: .center).background(Color(.systemGroupedBackground)), label: {
                        Text("Force Simulate All")
                    })
                    /*
                     NavigationLink(destination:
                         ScrollView(.vertical, showsIndicators: false, content: {
                             VStack{
                                 Button(action: { import_instruments() }, label: {
                                     Text("Import All from Test")
                                 })
                                 .buttonStyle(FilledButton())
                             }
                             .frame(maxWidth: .infinity,alignment: .center)
                             .padding()
                             .navigationBarTitle("Import")
                         }).frame(maxWidth: .infinity,alignment: .center).background(Color(.systemGroupedBackground)), label: {
                         Text("Import All from Test")
                     })
                     */
                    /*
                     NavigationLink(destination:
                         ScrollView(.vertical, showsIndicators: false, content: {
                             VStack{
                                 Button(action: { change_db() }, label: {
                                     Text("Change Database Location")
                                 })
                                 .buttonStyle(FilledButton())
                             }
                             .frame(maxWidth: .infinity,alignment: .center)
                             .padding()
                             .navigationBarTitle("Database")
                         }).frame(maxWidth: .infinity,alignment: .center).background(Color(.systemGroupedBackground)), label: {
                         Text("Change Database Location")
                     })
                     */
                }
            }
            .listStyle(InsetGroupedListStyle())
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationBarTitle("More", displayMode: .inline)
            .sheet(isPresented: $isPresent, content: {
                EditInstrumentView(isPresent: $isPresent)
                    .environmentObject(USER)
            })
        }
    }
    
    func forceSync(){
        for item in USER.instruments{
            NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: item.instrument, reason: 2)
        }
        for item in USER.instruments{
            if item.config.rules == "sma"{
                NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: item.instrument, reason: 1)
            }
            else {
                NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: item.instrument, reason: 5)
            }
        }
    }
    
    func import_instruments(){
    }
    func change_db(){
    }
}

struct MoreTabView_Previews: PreviewProvider {
    static var previews: some View {
        MoreTabView(startupFinished: .constant(true))
    }
}
