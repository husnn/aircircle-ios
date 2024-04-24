//
//  Person.swift
//  Aircircle
//
//  Created by Husnain on 29/02/2024.
//

import Foundation

struct Person: Codable, Identifiable {
    var id: Int64?;
    var name: String;
    var avatar: URL?;
    var bio: String?;
    var connectedAt = Date();
    var createdAt = Date();
}
