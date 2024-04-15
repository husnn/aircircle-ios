//
//  SecondaryButton.swift
//  Jono
//
//  Created by Husnain on 04/03/2024.
//

import SwiftUI

struct SecondaryButton: View {
    let text: String
    let icon: UIImage?
    let onTap: () -> Void
    
    init(text: String, icon: UIImage? = nil, onTap: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap,  label: {
            if icon != nil {
                Image(uiImage: icon!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFit()
            }
            Text(text)
        })
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .font(.body())
        .background(Color.jonoOlive)
        .foregroundStyle(Color.black)
        .clipShape(Capsule())
    }
}

#Preview {
    SecondaryButton(text: "Import from Contacts", icon: UIImage(named: "ic_contacts"), onTap: {})
}
