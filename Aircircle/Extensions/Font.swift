//
//  Font.swift
//  Aircircle
//
//  Created by Husnain on 28/02/2024.
//

import SwiftUI

enum CustomFont: String {
    case regular = "SFPro-Regular"
    case light = "SFPro-Light"
    case semibold = "SFPro-Semibold"
    case bold = "SFPro-Bold"
}

extension Font {
    static func custom(_ font: CustomFont, size: CGFloat) -> SwiftUI.Font {
        SwiftUI.Font.custom(font.rawValue, size: size)
    }
    
    static func body() -> SwiftUI.Font {
        .system(size: 16, weight: .regular)
    }
    
    static func title() -> SwiftUI.Font {
        .system(size: 21, weight: .bold)
    }
    
    static func largeTitle() -> SwiftUI.Font {
        .system(size: 28, weight: .bold)
    }
    
    static func label() -> SwiftUI.Font {
        .system(size: 14, weight: .light)
    }
}
