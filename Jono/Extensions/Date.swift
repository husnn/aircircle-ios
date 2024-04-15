//
//  Date.swift
//  Jono
//
//  Created by Husnain on 29/02/2024.
//

import Foundation

extension Date {
    func format(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
