//
//  EditInstrumentView.swift
//  AlgoTrade
//
//  Created by fung on 15/7/2021.
//

import SwiftUI

struct EditInstrumentView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresent: Bool
    @State var editMode = EditMode.inactive
    @State var presentAlert: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                if USER.instruments.count == 0 {
                    Spacer()
                    Text("No Instrument")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                else {
                    List{
                        ForEach(0 ..< USER.instruments.count, id: \.self){index in
                            Text(USER.instruments[index].instrument)
                        }
                        .onMove(perform: { indices, newOffset in
                            move(from: indices, to: newOffset)
                        })
                        .onDelete(perform: { indexSet in
                            remove(atIndex: indexSet)
                        })
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {isPresent = false}, label: {
                        Text("Close")
                    })
                }
            })
            .alert(isPresented: $presentAlert) {
                Alert(title: Text("Cannot Modify Database"), message: Text("You will receive a notification once all existing trigger are finished processing"), dismissButton: .default(Text("OK"),action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            }
            .onAppear(perform: {
                NetworkService.shared.get_trigger_count { count in
                    //debugPrint(count)
                    if count == 0{}
                    else {
                        presentAlert = true
                    }
                }
            })
            .navigationBarTitle("Existing Instruments", displayMode: .inline)
            .environment(\.editMode, $editMode)
        }
    }
    //MARK: check trigger count first
    func move(from: IndexSet, to: Int){
        USER.instruments.move(fromOffsets: from, toOffset: to)
        USER.last_updated = Int(Date().timeIntervalSince1970)
        USER.saveToFIR()
    }
    func remove(atIndex: IndexSet){
        USER.instruments.remove(atOffsets: atIndex)
        USER.last_updated = Int(Date().timeIntervalSince1970)
        USER.saveToFIR()
    }
}

struct EditInstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        EditInstrumentView(isPresent: .constant(true))
    }
}
