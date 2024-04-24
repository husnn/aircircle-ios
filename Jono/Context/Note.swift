//
//  Note.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import Foundation

struct Note: Codable, Identifiable {
    var id: Int64?;
    var personId: Int64;
    var text: String;
    var createdAt = Date();
}

