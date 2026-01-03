//
//  DateHelpers.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation

/// Centralized date and time utilities for the app
enum DateHelpers {
    private static let calendar = Calendar.current
    
    /// Returns the start of today (midnight)
    static var today: Date {
        calendar.startOfDay(for: Date())
    }
    
    /// Returns the start of tomorrow (midnight)
    static var tomorrow: Date {
        calendar.date(byAdding: .day, value: 1, to: today)!
    }
    
    /// Checks if a date is today
    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    /// Checks if a date is tomorrow
    static func isTomorrow(_ date: Date) -> Bool {
        calendar.isDateInTomorrow(date)
    }
    
    /// Normalizes a date to midnight (start of day)
    static func normalizeToDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    /// Checks if two dates are on the same day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// Formats a date for display (localized)
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Returns a date string appropriate for the context (Today, Tomorrow, or date)
    static func displayString(for date: Date) -> String {
        if isToday(date) {
            return NSLocalizedString("today", comment: "")
        } else if isTomorrow(date) {
            return NSLocalizedString("tomorrow", comment: "")
        } else {
            return formatDate(date)
        }
    }
}
