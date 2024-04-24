//
//  ContextService.swift
//  Aircircle
//
//  Created by Husnain on 04/03/2024.
//

import Foundation
import GRDB

struct NoteResult {
    let note: Note
    let person: Person
}

class ContextService: ObservableObject {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func handleRecording(fileURL: URL) async throws -> AudioResult {
        var notes: [SuggestedNote] = []
        
        let res = try await self.networkManager.uploadFile(fileURL,
                                                           type: "audio/wave",
                                                           to: "\(Constants.BaseAPIURL)/v0.1/context/upload_audio",
                                                           headers: [:],
                                                           progressHandler: { _ in },
                                                           continuationHandler: { true })
        guard var res = res else {
            return AudioResult(notes: [])
        }
        
        // NOTE: JSON data is returned here.
        let parsed = try AircircleAnalysisPB_UploadAudioFileResponse(jsonUTF8Data: res)
        
        res = try await self.networkManager.requestAsync(ContextEndpoint.getAudioResult(fileId: parsed.fileID))
        
        let resultParsed = try AircircleAnalysisPB_AudioResultResponse(serializedData: res)
        
        let all = try await dbPool.read { db in
            try Person.fetchAll(db)
        }
        
        for (i, n) in resultParsed.notes.enumerated() {
            var closestMatchPerson: Person? = nil
            var closestMatchDist = 10
            
            for p in all {
                let dist = Tools.levenshtein(aStr: p.name, bStr: n.person)
                
                if dist < closestMatchDist {
                    closestMatchPerson = p
                    closestMatchDist = dist
                }
            }
            
            let note = Note(id: Int64(i), personId: closestMatchPerson?.id ?? -1, text: n.text)
            dump(note)
            
            notes.append(SuggestedNote(person: closestMatchPerson, note: note))
        }
        
        return AudioResult(notes: notes)
    }
    
    func createNote(_ note: Note) {
        do {
            try dbPool.write { db in
                var n = note
                try n.insert(db)
            }
        } catch {
            print("Could not save note: \(error.localizedDescription)")
        }
    }
    
    func getNotesForPerson(id personId: Int64) -> [Note] {
        var notes: [Note] = []
        
        do {
            try dbPool.read { db in
                notes = try Note
                    .filter(Column("personId") == personId)
                    .order(Column("createdAt").desc)
                    .fetchAll(db)
            }
        } catch {
            print("Could not get notes for person: \(error.localizedDescription)")
        }
        
        return notes
    }
    
    func deleteNote(_ id: Int64) {
        do {
            _ = try dbPool.write { db in
                try Note.deleteOne(db, id: id)
            }
        } catch {
            print("Could not delete note: \(error.localizedDescription)")
        }
    }
    
    func search(_ term: String) -> [NoteResult] {
        var notes: [NoteResult] = []
        
        do {
            try dbPool.read { db in
                let sql = """
                    SELECT note.*
                    FROM note
                    JOIN note_ft
                        ON note_ft.rowid = note.rowid
                        AND note_ft MATCH ?
                    ORDER BY rank desc
                    """
                
                let pattern = FTS5Pattern(matchingPhrase: term)
                notes = try Note.fetchAll(db, sql: sql, arguments: [pattern])
                    .compactMap() { n in
                        if let person = try n.person.fetchOne(db) {
                            return NoteResult(note: n, person: person)
                        }
                        return nil
                    }
            }
        } catch {
            print("Could not search for Note records. \(error.localizedDescription)")
        }
        
        return notes
    }
}

struct AudioResult {
    var notes: [SuggestedNote]
}

enum ContextEndpoint: Endpoint {
    case getAudioResult(fileId: String)
    
    var path: String {
        switch self {
        case .getAudioResult:
            return "/v0.1/context/get_audio_result"
        }
        
    }
    var method: HttpMethod {
        switch self {
        default:
            return HttpMethod.post
        }
    }
    
    var body: Data? {
        switch self {
        case .getAudioResult(let fileId):
            let body = AircircleAnalysisPB_AudioResultRequest.with {
                $0.fileID = fileId
            }
            
            return try? body.serializedData()
        }
    }
}
