//
//  InstrumentView.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import SwiftUI

struct InstrumentView: View {
    
    @EnvironmentObject var USER: DBUSER
    @State var selectionIndex: Int
    @State var optionIndex: Int = 0
    @State var options = ["Transactions", "Strategy"]
    @State var presentAlert: Bool = false
    @State var isPresented: Bool = false
    
    var body: some View {
         if selectionIndex >= 0 && selectionIndex < USER.instruments.count{
             VStack{
                 VStack{
                     CurrentView(instrument: USER.instruments[selectionIndex])
                     HStack{
                         Button {
                             addTrigger(reason: 1)
                         } label: {
                             Text("Transactions")
                                .contentShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                         }
                         .buttonStyle(FilledButton())
                         .frame(height: 50)
                         Button {
                             addTrigger(reason: 2)
                         } label: {
                             Text("Strategy")
                                .contentShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                         }
                         .buttonStyle(FilledButton())
                         .frame(height: 50)
                         Button {
                            markAllTransactionDone()
                         } label: {
                             Text("Toggle All")
                                .contentShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                         }
                         .buttonStyle(FilledButton())
                         .frame(height: 50)
                     }
                     Picker("View", selection: $optionIndex) {
                         ForEach(0 ..< options.count) { index in
                             Text(self.options[index]).tag(index)
                         }
                     }
                     .pickerStyle(SegmentedPickerStyle())
                 }
                 .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                 InstrumentDetailsListView(optionIndex: $optionIndex, selectionIndex: $selectionIndex)
             }
             .ignoresSafeArea(.container, edges: .bottom)
             .background(Color(.systemGroupedBackground))
             .alert(isPresented: $presentAlert) {
                 Alert(title: Text("Cannot Modify Database"), message: Text("You will receive a notification once all existing trigger are finished processing"), dismissButton: .default(Text("OK")))
             }
             .sheet(isPresented: $isPresented, content: {
                NewStrategyView(index: $selectionIndex)
                    .environmentObject(USER)
             })
             .navigationBarTitle(USER.instruments[selectionIndex].instrument, displayMode: .inline)
             .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresented = true
                    }, label: {
                        Image(systemName: "note.text.badge.plus")
                            .font(.headline)
                    })
                }
             })
         }
     }
        
    func markAllTransactionDone(){
        //MARK: check trigger count first
        NetworkService.shared.get_trigger_count { count in
            if count == 0 {
                for items in USER.instruments[selectionIndex].transactions{
                    items.done.toggle()
                }
                USER.instruments[selectionIndex].last_updated_transactions = Int(Date().timeIntervalSince1970)
                USER.saveToFIR()
            }
            else {
                presentAlert = true
            }
        }
    }
    
    func addTrigger(reason: Int = 0){
        NetworkService.shared.get_trigger_count { count in
            if count == 0{
                if reason == 1{
                    if USER.instruments[selectionIndex].config.rules == "sma" {
                        NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: USER.instruments[selectionIndex].instrument, reason: 1)
                    }
                    else if USER.instruments[selectionIndex].config.rules == "macd" {
                        NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: USER.instruments[selectionIndex].instrument, reason: 5)
                    }
                }
                else if reason == 2 {
                    NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: USER.instruments[selectionIndex].instrument, reason: 2)
                }
            }
            else {
                presentAlert = true
            }
        }
        
    }
}

struct InstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(selectionIndex: 0)
    }
}
