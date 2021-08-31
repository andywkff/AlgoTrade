//
//  DefaultView.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import SwiftUI

struct DefaultView: View {
    
    @EnvironmentObject var USER: DBUSER
    @State var size: GeometryProxy? = nil
    @State var presentAlert: Bool = false
    @State var selectedIndex: Int = 0
    @State var isActive: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 10){
                if USER.instruments.count == 0 {
                    Spacer()
                    Text("No Instrument")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                else {
                    Group{
                        ForEach(USER.instruments, id: \.self.instrument){item in
                            Button(action: {
                                selectedIndex = USER.instruments.firstIndex{$0 === item} ?? 0
                                debugPrint("button pressed")
                                isActive = true
                            }, label: {
                                CurrentView(instrument: item)
                            })
                            .buttonStyle(ScaledButton())
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: InstrumentView(selectionIndex: selectedIndex), isActive: $isActive, label: {
                    EmptyView()
                }).hidden()
            )
            .padding(.all, 10)
            .alert(isPresented: $presentAlert) {
                Alert(title: Text("Cannot Modify Database"), message: Text("You will receive a notification once all existing trigger are finished processing"), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitle("Home", displayMode: .inline)
        .frame(maxWidth: .infinity,alignment: .center)
        .background(Color(.systemGroupedBackground))
    }
    func delete(atIndex: Int){
        NetworkService.shared.get_trigger_count { count in
            if count == 0 {
                USER.instruments.remove(at: atIndex)
                USER.last_updated = Int(Date().timeIntervalSince1970)
                USER.saveToFIR()
            }
            else {
                presentAlert = true
            }
        }
    }
}

struct DefaultView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultView()
    }
}
