//
//  Reservation.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftData

/// Represents a customer reservation for a specific time slot
@Model
final class Reservation {
    @Attribute(.unique) var id: UUID
    var customerName: String
    var phoneNumber: String
    var date: Date // Day resolution only
    var timeSlotHour: Int // 0-23
    var timeSlotMinute: Int // 0 or 30
    
    /// Relationship to hairdresser (many-to-one)
    var hairdresser: Hairdresser?
    
    init(
        id: UUID = UUID(),
        customerName: String,
        phoneNumber: String,
        date: Date,
        timeSlot: TimeSlot,
        hairdresser: Hairdresser
    ) {
        self.id = id
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        // Normalize date to midnight for day-level comparison
        self.date = Calendar.current.startOfDay(for: date)
        self.timeSlotHour = timeSlot.hour
        self.timeSlotMinute = timeSlot.minute
        self.hairdresser = hairdresser
    }
    
    /// Convenience property to get TimeSlot from stored hour and minute
    var timeSlot: TimeSlot {
        get {
            TimeSlot(hour: timeSlotHour, minute: timeSlotMinute)
        }
        set {
            timeSlotHour = newValue.hour
            timeSlotMinute = newValue.minute
        }
    }
    
    /// Returns the formatted time string for display
    var formattedTime: String {
        timeSlot.toString()
    }
    
    /// Returns the normalized date (start of day)
    var normalizedDate: Date {
        Calendar.current.startOfDay(for: date)
    }
}
