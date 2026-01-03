//
//  Validation.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation

/// Validation utilities for user inputs
enum Validation {
    
    /// Validates customer name
    /// - Parameter name: The name to validate
    /// - Returns: Error message if invalid, nil if valid
    static func validateCustomerName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return NSLocalizedString("empty_name_error", comment: "")
        }
        return nil
    }
    
    /// Validates phone number
    /// - Parameter phone: The phone number to validate
    /// - Returns: Error message if invalid, nil if valid
    static func validatePhoneNumber(_ phone: String) -> String? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return NSLocalizedString("empty_phone_error", comment: "")
        }
        return nil
    }
    
    /// Validates hairdresser name
    /// - Parameter name: The name to validate
    /// - Returns: Error message if invalid, nil if valid
    static func validateHairdresserName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return NSLocalizedString("empty_name_error", comment: "")
        }
        return nil
    }
    
    /// Validates all reservation fields
    /// - Parameters:
    ///   - customerName: Customer name
    ///   - phoneNumber: Phone number
    /// - Returns: Array of error messages (empty if all valid)
    static func validateReservation(customerName: String, phoneNumber: String) -> [String] {
        var errors: [String] = []
        
        if let nameError = validateCustomerName(customerName) {
            errors.append(nameError)
        }
        
        if let phoneError = validatePhoneNumber(phoneNumber) {
            errors.append(phoneError)
        }
        
        return errors
    }
}
