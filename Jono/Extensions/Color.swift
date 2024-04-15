//
//  Color.swift
//  Jono
//
//  Created by Husnain on 28/02/2024.
//

import SwiftUI

public extension Color {
    static let jonoGreen = Color("LightGreenColor")
    static let jonoOlive = Color("OliveColor")
    static let jonoYellow = Color("LightYellowColor")
    static let jonoDarkGrey = Color("DarkGreyColor")
    static let jonoBlack = Color("AlmostBlackColor")
    
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
