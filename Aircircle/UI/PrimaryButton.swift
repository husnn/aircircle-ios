//
//  PrimaryButton.swift
//  Aircircle
//
//  Created by Husnain on 01/03/2024.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .font(.system(size: 16, weight: .semibold))
            .background(Color.aircircleGreen)
            .foregroundStyle(configuration.isPressed ? .gray : .black)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.5)
    }
}

#Preview {
    Button(action: {}, label: {
        Text("Save changes")
    })
    .buttonStyle(PrimaryButton())
}
