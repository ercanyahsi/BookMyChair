//
//  Hairdresser.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import Foundation
import SwiftData

/// Represents a hairdresser in the system
@Model
final class Hairdresser {
    @Attribute(.unique) var id: UUID
    var name: String
    
    /// Relationship to reservations (one-to-many)
    @Relationship(deleteRule: .cascade, inverse: \Reservation.hairdresser)
    var reservations: [Reservation]
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.reservations = []
    }
}
