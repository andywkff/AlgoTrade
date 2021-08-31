//
//  CurrentView.swift
//  AlgoTrade
//
//  Created by fung on 13/7/2021.
//

import SwiftUI

struct CurrentView: View {
    
    @EnvironmentObject var USER: DBUSER
    @State var instrument: DBUSER_Instrument
    
    var body: some View {
        VStack (alignment: .trailing){
            HStack{
                Text(instrument.instrument)
                    .font(.largeTitle)
                Spacer()
                VStack{
                    Text(instrument.config.rules)
                        .font(.title)
                    Text("Rule")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            HStack{
                VStack {
                    HStack(spacing: 0){
                        Text(String(instrument.config.value))
                            .font(.body)
                        Text(", ")
                        Text(String(instrument.config.fastEMA))
                            .font(.body)
                        Text(", ")
                        Text(String(instrument.config.slowEMA))
                            .font(.body)
                        Text(", ")
                        Text(String(instrument.config.signalEMA))
                            .font(.body)
                    }
                    Text("SMA, fast, slow, signal")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text(instrument.config.test_period)
                        .font(.body)
                    Text("Test Length")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text(String(format: "%.2f", instrument.transactions.last?.price ?? 0))
                        .font(.body)
                    Text("Position")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            HStack{
                VStack{
                    Text(String(instrument.transactions.last?.date.prefix(10) ?? "No Date"))
                        .font(.body)
                    Text("Last transaction date")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text(String(format: "%.2f", instrument.config.portfolio))
                        .font(.body)
                    Text("Portfolio")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack{
                    Text(instrument.transactions.last?.direction ?? "buy")
                        .font(.headline)
                        .font(.body)
                    Text("Direction")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .contentShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground)))
    }
}

struct CurrentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentView(instrument: DBUSER_Instrument())
    }
}
