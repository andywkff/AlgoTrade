//
//  ButtonStyle.swift
//  AlgoTrade
//
//  Created by fung on 15/7/2021.
//

import SwiftUI

struct FilledButton: ButtonStyle {
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .light)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.all,5)
            .foregroundColor(.white)
            .background(configuration.isPressed ? .secondary : Color.accentColor)
            .cornerRadius(13)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .onChange(of: configuration.isPressed) { value in
                impactFeedback.impactOccurred()
            }
    }
}

struct ScaledButton: ButtonStyle {
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .light)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .onChange(of: configuration.isPressed) { value in
                impactFeedback.impactOccurred()
            }
    }
}
