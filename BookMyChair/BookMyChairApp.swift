//
//  BookMyChairApp.swift
//  BookMyChair
//
//  Created by Ercan Yahşi on 3.01.2026.
//

import SwiftUI
import SwiftData

@main
struct BookMyChairApp: App {
    /// SwiftData model container
    let modelContainer: ModelContainer
    
    /// Data store for the app
    let dataStore: AppDataStore
    
    init() {
        do {
            // Configure SwiftData model container with our models
            let schema = Schema([
                Hairdresser.self,
                Reservation.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            dataStore = AppDataStore(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore: dataStore)
        }
        .modelContainer(modelContainer)
    }
}
