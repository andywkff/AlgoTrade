//
//  InstrumentDetailsListView.swift
//  AlgoTrade
//
//  Created by fung on 13/7/2021.
//

import SwiftUI

struct InstrumentDetailsListView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Binding var optionIndex: Int
    @Binding var selectionIndex: Int
    @State var presentAlert: Bool = false
    
    var body: some View {
        if selectionIndex >= 0 && selectionIndex < USER.instruments.count{
            List{
                if optionIndex == 0{
                    Group{
                        ForEach((0..<USER.instruments[selectionIndex].transactions.count).reversed(), id: \.self){index in
                            Button(action:{
                                    USER.instruments[selectionIndex].transactions[index].done.toggle()
                                    USER.instruments[selectionIndex].last_updated_transactions = Int(Date().timeIntervalSince1970)
                                    USER.saveToFIR()
                            }, label:{
                                HStack{
                                    Text(USER.instruments[selectionIndex].transactions[index].direction)
                                        .font(.title)
                                    Text(String(format: "%.2f", USER.instruments[selectionIndex].transactions[index].price))
                                        .font(.title2)
                                    Text(USER.instruments[selectionIndex].transactions[index].date.prefix(10))
                                        .font(.body)
                                }
                            })
                            .foregroundColor(USER.instruments[selectionIndex].transactions[index].done ? .secondary : .accentColor)
                        }
                    }
                }
                else if optionIndex == 1{
                    Group{
                        ForEach((0..<USER.instruments[selectionIndex].config_simulation_history.count).reversed(), id: \.self){index in
                            Button(action:{
                                setConfig(index: index) { value in
                                    if value {
                                        addTrigger()
                                    }
                                    else {
                                        presentAlert = true
                                    }
                                }
                            }, label:{
                                VStack(alignment: .leading){
                                    HStack{
                                        Text(String(USER.instruments[selectionIndex].config_simulation_history[index].rules))
                                            .font(.title)
                                        Text(String(USER.instruments[selectionIndex].config_simulation_history[index].value))
                                            .font(.title2)
                                        Text(USER.instruments[selectionIndex].config_simulation_history[index].test_period)
                                            .font(.headline)
                                        Text(String(format: "%.2f", USER.instruments[selectionIndex].config_simulation_history[index].portfolio))
                                            .font(.body)
                                    }
                                }
                            })
                            .foregroundColor(USER.instruments[selectionIndex].config_simulation_history[index].active ? .accentColor : .secondary)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .alert(isPresented: $presentAlert) {
                Alert(title: Text("Cannot Modify Database"), message: Text("You will receive a notification once all existing trigger are finished processing"), dismissButton: .default(Text("OK")))
            }
        }
    }
    func setConfig(index: Int, completion: @escaping (Bool) -> Void){
        NetworkService.shared.get_trigger_count { count in
            if count == 0{
                for item in USER.instruments[selectionIndex].config_simulation_history{
                    item.active = false
                }
                USER.instruments[selectionIndex].config_simulation_history[index].active = true
                USER.instruments[selectionIndex].config = USER.instruments[selectionIndex].config_simulation_history[index]
                USER.instruments[selectionIndex].config_history.append(USER.instruments[selectionIndex].config_simulation_history[index])
                USER.instruments[selectionIndex].transactions.removeAll()
                USER.instruments[selectionIndex].last_updated_best = Int(Date().timeIntervalSince1970)
                USER.instruments[selectionIndex].last_updated_transactions = Int(Date().timeIntervalSince1970)
                USER.saveToFIR()
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    func addTrigger(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if USER.instruments[selectionIndex].config.rules == "sma" {
                NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: USER.instruments[selectionIndex].instrument, reason: 1)
            }
            else if USER.instruments[selectionIndex].config.rules == "macd" {
                NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: USER.instruments[selectionIndex].instrument, reason: 5)
            }
        }
    }
}

struct InstrumentDetailsListView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentDetailsListView(optionIndex: .constant(0), selectionIndex: .constant(0))
    }
}
