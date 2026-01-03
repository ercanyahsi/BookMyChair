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
        }
    }
    
    /// Available hours (0-23)
    var availableHours: [Int] {
        Array(0...23)
    }
    
    /// Available minutes (0, 30)
    var availableMinutes: [Int] {
        [0, 30]
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
