//
//  Int.swift
//  Aircircle
//
//  Created by Husnain on 10/03/2024.
//

import Foundation

extension Int {

    func secondsAsLength() -> String {
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return String(format: "%d:%02d", m, s)
    }
}
