//
//  Color.swift
//  Aircircle
//
//  Created by Husnain on 28/02/2024.
//

import SwiftUI

public extension Color {
    static let aircircleGreen = Color("LightGreenColor")
    static let aircircleOlive = Color("OliveColor")
    static let aircircleYellow = Color("LightYellowColor")
    static let aircircleDarkGrey = Color("DarkGreyColor")
    static let aircircleLightGrey = Color("LightGreyColor")
    static let aircircleBlack = Color("AlmostBlackColor")
    
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
