//
//  ReservationEditorViewModel.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftUI
import Observation

/// ViewModel for creating and editing reservations
@MainActor
@Observable
class ReservationEditorViewModel {
    var customerName: String = ""
    var phoneNumber: String = ""
    var selectedHour: Int = 9
    var selectedMinute: Int = 0
    var errorMessage: String?
    var showingDeleteConfirmation = false
    var showingConflictAlert = false
    
    let hairdresser: Hairdresser
    let date: Date
    let reservation: Reservation? // nil for new, non-nil for edit
    
    private let dataStore: AppDataStore
    private let onSave: () -> Void
    
    var isEditing: Bool {
        reservation != nil
    }
    
    var title: String {
        isEditing
            ? NSLocalizedString("edit_reservation", comment: "")
            : NSLocalizedString("new_reservation", comment: "")
    }
    
    init(
        hairdresser: Hairdresser,
        date: Date,
        reservation: Reservation? = nil,
        dataStore: AppDataStore,
        onSave: @escaping () -> Void
    ) {
        self.hairdresser = hairdresser
        self.date = date
        self.reservation = reservation
        self.dataStore = dataStore
        self.onSave = onSave
        
        // Pre-populate fields if editing
        if let reservation = reservation {
            self.customerName = reservation.customerName
            self.phoneNumber = reservation.phoneNumber
            self.selectedHour = reservation.timeSlotHour
            self.selectedMinute = reservation.timeSlotMinute
        } else {
            // Set default time for new reservations
            let calendar = Calendar.current
            let now = Date()
            
            // If date is today, use current time + 1 hour
            // If date is tomorrow or future, use 08:00
            if calendar.isDateInToday(date) {
                let currentHour = calendar.component(.hour, from: now)
                var defaultHour = currentHour + 1
                
                // Ensure default hour is within business hours (8-21)
                if defaultHour < 8 {
                    defaultHour = 9
                } else if defaultHour > 21 {
                    defaultHour = 9
                }
                
                self.selectedHour = defaultHour
            } else {
                // For tomorrow or future dates, default to 08:00
                self.selectedHour = 8
            }
            
            self.selectedMinute = 0
        }
    }
    
    /// Available hours (8-21 for business hours)
    var availableHours: [Int] {
        let allHours = Array(8...21)
        
        // If date is today, filter out past hours
        if Calendar.current.isDateInToday(date) {
            let now = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            return allHours.filter { hour in
                // Include hours greater than current hour
                if hour > currentHour {
                    return true
                }
                // For current hour, only include if we can still book 30-min slot
                if hour == currentHour && currentMinute < 30 {
                    return true
                }
                return false
            }
        }
        
        return allHours
    }
    
    /// Available minutes (0, 30)
    var availableMinutes: [Int] {
        // If date is today and selected hour is current hour, filter past minutes
        if Calendar.current.isDateInToday(date) {
            let now = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            if selectedHour == currentHour {
                // Only show :30 if current time is before :30
                if currentMinute < 30 {
                    return [30]
                } else {
                    return [] // No available minutes for this hour
                }
            }
        }
        
        return [0, 30]
    }
    
    /// Validate and save the reservation
    func save() {
        // Validate inputs
        let validationErrors = Validation.validateReservation(
            customerName: customerName,
            phoneNumber: phoneNumber
        )
        
        if !validationErrors.isEmpty {
            errorMessage = validationErrors.joined(separator: "\n")
            return
        }
        
        // Validate time is not in the past
        if Calendar.current.isDateInToday(date) {
            let now = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            if selectedHour < currentHour || (selectedHour == currentHour && selectedMinute <= currentMinute) {
                errorMessage = NSLocalizedString("past_time_error", comment: "")
                return
            }
        }
        
        let timeSlot = TimeSlot(hour: selectedHour, minute: selectedMinute)
        
        do {
            if let reservation = reservation {
                // Update existing reservation
                try dataStore.updateReservation(
                    reservation,
                    customerName: customerName.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                    date: date,
                    timeSlot: timeSlot
                )
            } else {
                // Create new reservation
                _ = try dataStore.createReservation(
                    customerName: customerName.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                    date: date,
                    timeSlot: timeSlot,
                    hairdresser: hairdresser
                )
            }
            
            onSave()
        } catch ReservationError.timeConflict {
            showingConflictAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Delete the reservation (only available when editing)
    func delete() {
        guard let reservation = reservation else { return }
        
        do {
            try dataStore.deleteReservation(reservation)
            onSave()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Show delete confirmation dialog
    func confirmDelete() {
        showingDeleteConfirmation = true
    }
}
