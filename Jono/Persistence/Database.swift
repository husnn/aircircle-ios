//
//  Database.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import Foundation
import GRDB

var dbPool: DatabasePool!

class Database {
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("initial", migrate: { db in
            try db.create(table: "person", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("bio", .text)
                t.column("avatar", .text)
                t.column("connectedAt", .date).notNull()
                t.column("createdAt", .date).notNull()
            })
            
            try db.create(table: "note", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("personId", .integer)
                    .references("person", onDelete: .cascade)
                t.column("text", .text).notNull()
                t.column("createdAt", .date).notNull()
            })
            
            try db.create(virtualTable: "person_ft", using: FTS5()) { t in
                t.synchronize(withTable: "person")
                t.tokenizer = .porter()
                t.column("name")
                t.column("bio")
            }
            
            try db.create(virtualTable: "note_ft", using: FTS5()) { t in
                t.synchronize(withTable: "note")
                t.tokenizer = .porter()
                t.column("text")
            }
        })
        
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        return migrator
    }
    
    static func setup() throws {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputPath = dir.appendingPathComponent("db.sqlite")
        
        dbPool = try DatabasePool(path: outputPath.path())
        
        try migrator.migrate(dbPool)
    }
}
