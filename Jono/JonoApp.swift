//
//  JonoApp.swift
//  Jono
//
//  Created by Husnain on 27/02/2024.
//

import SwiftUI
import SwiftData

@main
struct JonoApp: App {
    let contextService: ContextService
    let personService: PersonService
    
    init() {
        try? Database.setup()
        
        let networkManager = NetworkManager()
        
        contextService = ContextService(networkManager: networkManager)
        personService = PersonService()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contextService)
                .environmentObject(personService)
        }
    }
}
