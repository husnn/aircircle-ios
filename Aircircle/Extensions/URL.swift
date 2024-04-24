//
//  URL.swift
//  Aircircle
//
//  Created by Husnain on 14/03/2024.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
    
    func exists() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            return true
        } else {
            return false
        }
    }
    
    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(at: self)
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
        return true
    }
    
    func deleteIfExists() -> Bool {
        if exists() {
            return delete()
        }
        return true
    }
    
    func ensureParentExists() throws {
        if !FileManager.default.fileExists(atPath: self.path) {
            try FileManager.default.createDirectory(atPath: self.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func move(_ to: URL) throws {
        try to.ensureParentExists()
        try FileManager.default.moveItem(at: self, to: to)
    }
    
    func clearContents() throws {
        let fileName = try FileManager.default.contentsOfDirectory(atPath: self.absoluteString)
            
        for file in fileName {
            let filePath = URL(fileURLWithPath: self.absoluteString).appendingPathComponent(file).absoluteURL
            try FileManager.default.removeItem(at: filePath)
        }
    }
}
