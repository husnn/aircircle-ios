//
//  ActionLabelView.swift
//  Jono
//
//  Created by Husnain on 29/02/2024.
//

import SwiftUI

struct ActionLabel: View {
    let text: String
    let icon: UIImage?
    let iconSize: CGSize
    let onTap: () -> Void
    
    init(text: String, icon: UIImage? = nil, iconSize: CGSize = CGSize(width: 20, height: 20), onTap: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.iconSize = iconSize
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap,  label: {
            if icon != nil {
                Image(uiImage: icon!)
                    .resizable()
                    .frame(width: iconSize.width, height: iconSize.height)
                    .scaledToFit()
            }
            Text(text)
        })
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .font(.body())
        .background(Color.jonoGreen)
        .foregroundStyle(Color.black)
        .clipShape(Capsule())
    }
}

#Preview {
    ActionLabel(text: "Add meeting", icon: UIImage(named: "ic_add_person"), onTap: {})
}
