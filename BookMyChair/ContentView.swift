//
//  ContentView.swift
//  BookMyChair
//
//  Created by Ercan Yahşi on 3.01.2026.
//

import SwiftUI
import SwiftData

/// Root content view of the application
struct ContentView: View {
    let dataStore: AppDataStore
    
    var body: some View {
        HairdresserSelectionView(dataStore: dataStore)
    }
}
