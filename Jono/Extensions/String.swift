//
//  String.swift
//  Jono
//
//  Created by Husnain on 29/02/2024.
//

import Foundation

extension String {
    
    func initials() -> String {
        var initials = "";
        
        for c in self.split(separator: " ") {
            if let first = c.first {
                initials += first.uppercased()
            }
        }
        
        return initials;
    }
}

extension String: LocalizedError {
    
    public var errorDescription: String? { return self }
}
