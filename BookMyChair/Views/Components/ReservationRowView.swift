//
//  ReservationRowView.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI

/// Component view for displaying a reservation in a list
struct ReservationRowView: View {
    let reservation: Reservation
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Time badge
            timeBadge
            
            // Customer information
            VStack(alignment: .leading, spacing: 6) {
                Text(reservation.customerName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(reservation.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reservation.formattedTime), \(reservation.customerName)")
        .accessibilityHint(NSLocalizedString("Tap to edit reservation", comment: ""))
    }
    
    private var timeBadge: some View {
        Text(reservation.formattedTime)
            .font(.system(.callout, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor)
            )
            .frame(width: 70)
    }
}
