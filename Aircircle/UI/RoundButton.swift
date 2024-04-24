//
//  RoundButton.swift
//  Aircircle
//
//  Created by Husnain on 29/02/2024.
//

import SwiftUI

struct RoundButton: View {
    let icon: UIImage
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {},  label: {
            Image(uiImage: icon)
                .resizable()
                .frame(width: 14, height: 20)
                .scaledToFit()
        })
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .font(.body())
        .background(Color.aircircleGreen)
        .foregroundStyle(Color.black)
        .clipShape(Circle())
    }
}

#Preview {
    RoundButton(icon: UIImage(named: "ic_microphone")!, onTap: {})
}
