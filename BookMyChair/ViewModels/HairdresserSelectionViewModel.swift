//
//  HairdresserSelectionViewModel.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftUI
import Observation

/// ViewModel for hairdresser selection and creation
@MainActor
@Observable
class HairdresserSelectionViewModel {
    var hairdressers: [Hairdresser] = []
    var showingCreateSheet = false
    var newHairdresserName = ""
    var errorMessage: String?
    
    let dataStore: AppDataStore
    
    init(dataStore: AppDataStore) {
        self.dataStore = dataStore
        loadHairdressers()
    }
    
    /// Load all hairdressers from data store
    func loadHairdressers() {
        hairdressers = dataStore.fetchHairdressers()
    }
    
    /// Create a new hairdresser
    func createHairdresser() {
        // Validate name
        if let error = Validation.validateHairdresserName(newHairdresserName) {
            errorMessage = error
            return
        }
        
        do {
            _ = try dataStore.createHairdresser(name: newHairdresserName.trimmingCharacters(in: .whitespacesAndNewlines))
            loadHairdressers()
            newHairdresserName = ""
            showingCreateSheet = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Delete a hairdresser
    func deleteHairdresser(_ hairdresser: Hairdresser) {
        do {
            try dataStore.deleteHairdresser(hairdresser)
            loadHairdressers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Reset the create form
    func resetCreateForm() {
        newHairdresserName = ""
        errorMessage = nil
    }
}
