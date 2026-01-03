//
//  TimeSlot.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation

/// Represents a 30-minute time slot in the hairdresser's schedule
/// Only allows HH:00 or HH:30 formats
struct TimeSlot: Codable, Hashable, Comparable {
    let hour: Int // 0-23
    let minute: Int // 0 or 30
    
    /// Create a new time slot
    /// - Parameters:
    ///   - hour: Hour of the day (0-23)
    ///   - minute: Minute (must be 0 or 30)
    init(hour: Int, minute: Int) {
        precondition(hour >= 0 && hour <= 23, "Hour must be between 0 and 23")
        precondition(minute == 0 || minute == 30, "Minute must be 0 or 30")
        
        self.hour = hour
        self.minute = minute
    }
    
    /// Create a time slot from a Date
    /// Rounds down to nearest valid slot (HH:00 or HH:30)
    init(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        // Round down to nearest valid slot
        let validMinute = minute < 30 ? 0 : 30
        self.init(hour: hour, minute: validMinute)
    }
    
    /// Convert time slot to string format (HH:MM)
    func toString() -> String {
        return String(format: "%02d:%02d", hour, minute)
    }
    
    /// Comparable conformance for sorting
    static func < (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        }
        return lhs.minute < rhs.minute
    }
    
    /// All possible time slots in a day
    static var allSlots: [TimeSlot] {
        var slots: [TimeSlot] = []
        for hour in 0...23 {
            slots.append(TimeSlot(hour: hour, minute: 0))
            slots.append(TimeSlot(hour: hour, minute: 30))
        }
        return slots
    }
}
