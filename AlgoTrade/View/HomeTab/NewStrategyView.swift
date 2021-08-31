//
//  NewStrategyView.swift
//  AlgoTrade
//
//  Created by fung on 11/8/2021.
//

import SwiftUI
import AlertToast

struct NewStrategyView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Environment(\.presentationMode) private var presentation
    @Binding var index: Int
    @State var strategySelection: Int = 0
    @State var tempConfig: DBUSER_InstrumentsConfig = DBUSER_InstrumentsConfig()
    @State var SMA: Int = 0
    @State var slowEMA: Int = 0
    @State var fastEMA: Int = 0
    @State var signalEMA: Int = 0
    @State var testPeriod: Int = 0
    @State var portfolio: Double = 0.0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .light)
    @State var showPrompt: Bool = false

    var body: some View {
        NavigationView{
            VStack{
                Picker(selection: $strategySelection, label: Text("Strategy"), content: {
                    Text("SMA").tag(0)
                    Text("MACD").tag(1)
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Form{
                    if strategySelection == 0 {
                        Group{
                            Section(header: Text("SMA")) {
                                TextField("Portfolio", value: $portfolio, formatter: NumberFormatter())
                                Stepper("SMA: \(SMA)", value: $SMA, in: 1...50, step: 1) { value in
                                    impactFeedback.impactOccurred()
                                }
                                Picker("Test Period", selection: $testPeriod) {
                                    Text("1yr").tag(1)
                                    Text("2yrs").tag(2)
                                    Text("3yrs").tag(3)
                                    Text("5yrs").tag(5)
                                }.pickerStyle(DefaultPickerStyle())
                            }
                        }
                        
                    }
                    else if strategySelection == 1 {
                        Group{
                            Section(header: Text("MACD")) {
                                TextField("Portfolio", value: $portfolio, formatter: NumberFormatter())
                                Stepper("SMA: \(SMA)", value: $SMA, in: 6...26, step: 1) { value in
                                    impactFeedback.impactOccurred()
                                }
                                Stepper("slowEMA: \(slowEMA)", value: $slowEMA, in: 11...35, step: 1) { value in
                                    impactFeedback.impactOccurred()
                                }
                                Stepper("fastEMA: \(fastEMA)", value: $fastEMA, in: 2...10, step: 1) { value in
                                    impactFeedback.impactOccurred()
                                }
                                Stepper("signalEMA: \(signalEMA)", value: $signalEMA, in: 2...20, step: 1) { value in
                                    impactFeedback.impactOccurred()
                                }
                                Picker("Test Period", selection: $testPeriod) {
                                    Text("1yr").tag(1)
                                    Text("2yrs").tag(2)
                                    Text("3yrs").tag(3)
                                    Text("5yrs").tag(5)
                                }.pickerStyle(DefaultPickerStyle())
                            }
                        }
                    }
                    
                }
            }
            .onAppear{
                if tempConfig.rules == "sma"{
                    strategySelection = 0
                    SMA = tempConfig.value
                    portfolio = tempConfig.portfolio
                    switch tempConfig.test_period[tempConfig.test_period.startIndex] {
                    case "1":
                        testPeriod = 1
                    case "2":
                        testPeriod = 2
                    case "3":
                        testPeriod = 3
                    case "5":
                        testPeriod = 5
                    default:
                        testPeriod = 0
                    }
                }
                else if tempConfig.rules == "macd"{
                    strategySelection = 1
                    SMA = tempConfig.value
                    fastEMA = tempConfig.fastEMA
                    slowEMA = tempConfig.slowEMA
                    signalEMA = tempConfig.signalEMA
                    portfolio = tempConfig.portfolio
                    switch tempConfig.test_period[tempConfig.test_period.startIndex] {
                    case "1":
                        testPeriod = 1
                    case "2":
                        testPeriod = 2
                    case "3":
                        testPeriod = 3
                    case "5":
                        testPeriod = 5
                    default:
                        testPeriod = 0
                    }
                }
            }
            .toast(isPresenting: $showPrompt, duration: 1.5, alert: {
                AlertToast(type: .complete(Color.green), title: "Success")
            })
            .navigationBarTitle("New Strategy", displayMode: .inline)
            .toolbar(content: {
               ToolbarItem(placement: .primaryAction) {
                   Button(action: {
                        save_strategy()
                   }, label: {
                       Text("Save")
                   })
               }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            })
        }
    }
    func save_strategy(){
        if strategySelection == 0 {
            tempConfig.instrument = USER.instruments[index].instrument
            tempConfig.portfolio = portfolio
            tempConfig.rules = "sma"
            tempConfig.value = SMA
            if testPeriod == 1{
                tempConfig.test_period = "\(testPeriod)yr"
            }
            else if testPeriod == 0{
                tempConfig.test_period = "2yrs"
            }
            else {
                tempConfig.test_period = "\(testPeriod)yrs"
            }
            tempConfig.last_updated = Int(Date().timeIntervalSince1970)
            tempConfig.created = Int(Date().timeIntervalSince1970)
            tempConfig.fastEMA = 0
            tempConfig.slowEMA = 0
            tempConfig.signalEMA = 0
        }
        else if strategySelection == 1 {
            tempConfig.instrument = USER.instruments[index].instrument
            tempConfig.portfolio = portfolio
            tempConfig.rules = "macd"
            tempConfig.value = SMA
            tempConfig.fastEMA = fastEMA
            tempConfig.slowEMA = slowEMA
            tempConfig.signalEMA = signalEMA
            if testPeriod == 1{
                tempConfig.test_period = "\(testPeriod)yr"
            }
            else if testPeriod == 0{
                tempConfig.test_period = "2yrs"
            }
            else {
                tempConfig.test_period = "\(testPeriod)yrs"
            }
            tempConfig.last_updated = Int(Date().timeIntervalSince1970)
            tempConfig.created = Int(Date().timeIntervalSince1970)
        }
        USER.instruments[index].config_simulation_history.append(tempConfig)
        USER.saveToFIR()
        showPrompt = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            presentation.wrappedValue.dismiss()
        }
    }
}

struct NewStrategyView_Previews: PreviewProvider {
    static var previews: some View {
        NewStrategyView(index: .constant(0))
    }
}
