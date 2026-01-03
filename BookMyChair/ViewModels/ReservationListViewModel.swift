//
//  ReservationListViewModel.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftUI
import Observation

/// ViewModel for the reservation list screen
@MainActor
@Observable
class ReservationListViewModel {
    var reservations: [Reservation] = []
    var selectedDate: Date = DateHelpers.today
    var showingEditor = false
    var editingReservation: Reservation?
    
    let hairdresser: Hairdresser
    let dataStore: AppDataStore
    
    init(hairdresser: Hairdresser, dataStore: AppDataStore) {
        self.hairdresser = hairdresser
        self.dataStore = dataStore
        loadReservations()
    }
    
    /// Load reservations for the current date
    func loadReservations() {
        reservations = dataStore.fetchReservations(for: hairdresser, on: selectedDate)
    }
    
    /// Switch to today's view
    func showToday() {
        selectedDate = DateHelpers.today
        loadReservations()
    }
    
    /// Switch to tomorrow's view
    func showTomorrow() {
        selectedDate = DateHelpers.tomorrow
        loadReservations()
    }
    
    /// Check if currently showing today
    var isShowingToday: Bool {
        DateHelpers.isSameDay(selectedDate, DateHelpers.today)
    }
    
    /// Check if currently showing tomorrow
    var isShowingTomorrow: Bool {
        DateHelpers.isSameDay(selectedDate, DateHelpers.tomorrow)
    }
    
    /// Get display title for current date
    var dateDisplayTitle: String {
        DateHelpers.displayString(for: selectedDate)
    }
    
    /// Present the editor for a new reservation
    func addReservation() {
        editingReservation = nil
        showingEditor = true
    }
    
    /// Present the editor for an existing reservation
    func editReservation(_ reservation: Reservation) {
        editingReservation = reservation
        showingEditor = true
    }
    
    /// Delete a reservation
    func deleteReservation(_ reservation: Reservation) {
        do {
            try dataStore.deleteReservation(reservation)
            loadReservations()
        } catch {
            // Error handling could be improved with alerts
            print("Error deleting reservation: \(error)")
        }
    }
}
