//
//  NewInstrumentView.swift
//  AlgoTrade
//
//  Created by fung on 13/7/2021.
//

import SwiftUI

struct NewInstrumentView: View {
    
    @EnvironmentObject var USER: DBUSER
    @Binding var isPresent: Bool
    @State var textInput: String = ""
    @State var stateText:String = ""
    @State var presentAlert: Bool = false
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                VStack{
                    TextField("Instrument Name", text: $textInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text(stateText)
                }
                .padding()
            }
            .alert(isPresented: $presentAlert) {
                Alert(title: Text("Cannot Modify Database"), message: Text("You will receive a notification once all existing trigger are finished processing"), dismissButton: .default(Text("OK")))
            }
            .onChange(of: textInput, perform: { value in
                stateText = ""
            })
            .navigationBarTitle("New", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addNew()
                    } label: {
                        Text("Save")
                    }
                    .disabled(textInput == "")
                }
            }
        }
    }
    
    func addNew(){
        var exist = false
        for item in USER.instruments{
            if item.instrument == textInput{
                exist = true
            }
        }
        if !exist {
            NetworkService.shared.get_trigger_count { count in
                if count == 0{
                    NetworkService.shared.add_trigger(user_id: USER.user_id, instrument: textInput, reason: 4)
                    withAnimation(.easeInOut(duration: 3)) {
                        textInput = ""
                        isPresent = false
                    }
                }
                else {
                    presentAlert = true
                }
            }
            
        }
    }
    
}

struct NewInstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        NewInstrumentView(isPresent: .constant(true))
    }
}
