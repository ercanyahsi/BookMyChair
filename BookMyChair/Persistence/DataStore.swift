//
//  DataStore.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftData
import Observation

/// Main data store for the application
/// Provides centralized access to SwiftData model context and common queries
@MainActor
@Observable
class AppDataStore {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    // MARK: - Hairdresser Operations
    
    /// Fetch all hairdressers
    func fetchHairdressers() -> [Hairdresser] {
        let descriptor = FetchDescriptor<Hairdresser>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Create a new hairdresser
    func createHairdresser(name: String) throws -> Hairdresser {
        let hairdresser = Hairdresser(name: name)
        modelContext.insert(hairdresser)
        try modelContext.save()
        return hairdresser
    }
    
    /// Delete a hairdresser
    func deleteHairdresser(_ hairdresser: Hairdresser) throws {
        modelContext.delete(hairdresser)
        try modelContext.save()
    }
    
    // MARK: - Reservation Operations
    
    /// Fetch reservations for a specific hairdresser and date
    func fetchReservations(for hairdresser: Hairdresser, on date: Date) -> [Reservation] {
        let normalizedDate = DateHelpers.normalizeToDay(date)
        let hairdresserId = hairdresser.id
        
        let descriptor = FetchDescriptor<Reservation>(
            predicate: #Predicate<Reservation> { reservation in
                reservation.hairdresser?.id == hairdresserId &&
                reservation.date == normalizedDate
            },
            sortBy: [
                SortDescriptor(\.timeSlotHour),
                SortDescriptor(\.timeSlotMinute)
            ]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Check if a time slot conflicts with existing reservations
    func hasConflict(
        hairdresser: Hairdresser,
        date: Date,
        timeSlot: TimeSlot,
        durationMinutes: Int,
        excluding reservationId: UUID? = nil
    ) -> Bool {
        let normalizedDate = DateHelpers.normalizeToDay(date)
        let existingReservations = fetchReservations(for: hairdresser, on: normalizedDate)
        
        // Convert new appointment to minutes since midnight
        let newStartMinutes = timeSlot.hour * 60 + timeSlot.minute
        let newEndMinutes = newStartMinutes + durationMinutes
        
        return existingReservations.contains { reservation in
            // Skip the reservation being edited
            if let excludeId = reservationId, reservation.id == excludeId {
                return false
            }
            
            // Convert existing appointment to minutes since midnight
            let existingStartMinutes = reservation.timeSlotHour * 60 + reservation.timeSlotMinute
            let existingEndMinutes = existingStartMinutes + reservation.durationMinutes
            
            // Check for overlap: two time ranges overlap if start1 < end2 AND start2 < end1
            return newStartMinutes < existingEndMinutes && existingStartMinutes < newEndMinutes
        }
    }
    
    /// Create a new reservation
    func createReservation(
        customerName: String,
        phoneNumber: String,
        date: Date,
        timeSlot: TimeSlot,
        hairdresser: Hairdresser,
        durationMinutes: Int = 60
    ) throws -> Reservation {
        // Check for conflicts
        if hasConflict(hairdresser: hairdresser, date: date, timeSlot: timeSlot, durationMinutes: durationMinutes) {
            throw ReservationError.timeConflict
        }
        
        let reservation = Reservation(
            customerName: customerName,
            phoneNumber: phoneNumber,
            date: date,
            timeSlot: timeSlot,
            hairdresser: hairdresser,
            durationMinutes: durationMinutes
        )
        
        modelContext.insert(reservation)
        try modelContext.save()
        
        // Schedule notifications for the new reservation
        Task {
            await NotificationManager.shared.scheduleNotifications(for: reservation)
        }
        
        return reservation
    }
    
    /// Update an existing reservation
    func updateReservation(
        _ reservation: Reservation,
        customerName: String,
        phoneNumber: String,
        date: Date,
        timeSlot: TimeSlot,
        durationMinutes: Int = 60
    ) throws {
        guard let hairdresser = reservation.hairdresser else {
            throw ReservationError.invalidData
        }
        
        // Check for conflicts (excluding current reservation)
        if hasConflict(
            hairdresser: hairdresser,
            date: date,
            timeSlot: timeSlot,
            durationMinutes: durationMinutes,
            excluding: reservation.id
        ) {
            throw ReservationError.timeConflict
        }
        
        reservation.customerName = customerName
        reservation.phoneNumber = phoneNumber
        reservation.date = DateHelpers.normalizeToDay(date)
        reservation.timeSlot = timeSlot
        reservation.durationMinutes = durationMinutes
        
        try modelContext.save()
        
        // Reschedule notifications with updated information
        Task {
            await NotificationManager.shared.scheduleNotifications(for: reservation)
        }
    }
    
    /// Delete a reservation
    func deleteReservation(_ reservation: Reservation) throws {
        let reservationId = reservation.id
        modelContext.delete(reservation)
        try modelContext.save()
        
        // Cancel any scheduled notifications
        Task {
            await NotificationManager.shared.cancelNotifications(for: reservationId)
        }
    }
}

// MARK: - Errors

enum ReservationError: LocalizedError {
    case timeConflict
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .timeConflict:
            return NSLocalizedString("conflict_message", comment: "")
        case .invalidData:
            return NSLocalizedString("validation_error", comment: "")
        }
    }
}
