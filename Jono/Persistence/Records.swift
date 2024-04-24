//
//  Records.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import GRDB

extension Person: FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    static let notes = hasMany(Note.self)
    
    var notes: QueryInterfaceRequest<Note> {
        request(for: Person.notes)
    }
}

extension Note: FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    static let person = belongsTo(Person.self)
    
    var person: QueryInterfaceRequest<Person> {
        request(for: Note.person)
    }
}
