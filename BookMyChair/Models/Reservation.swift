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
    var durationMinutes: Int = 60 // Duration in minutes (e.g., 30, 60, 90, 120)
    
    /// Relationship to hairdresser (many-to-one)
    var hairdresser: Hairdresser?
    
    init(
        id: UUID = UUID(),
        customerName: String,
        phoneNumber: String,
        date: Date,
        timeSlot: TimeSlot,
        hairdresser: Hairdresser,
        durationMinutes: Int = 60
    ) {
        self.id = id
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        // Normalize date to midnight for day-level comparison
        self.date = Calendar.current.startOfDay(for: date)
        self.timeSlotHour = timeSlot.hour
        self.timeSlotMinute = timeSlot.minute
        self.durationMinutes = durationMinutes
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
    
    /// Returns the formatted duration string for display
    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Returns the end time of the appointment
    var endTime: TimeSlot {
        let startMinutes = timeSlotHour * 60 + timeSlotMinute
        let endMinutes = startMinutes + durationMinutes
        let endHour = (endMinutes / 60) % 24
        let endMinute = endMinutes % 60
        return TimeSlot(hour: endHour, minute: endMinute)
    }
    
    /// Returns the normalized date (start of day)
    var normalizedDate: Date {
        Calendar.current.startOfDay(for: date)
    }
}
