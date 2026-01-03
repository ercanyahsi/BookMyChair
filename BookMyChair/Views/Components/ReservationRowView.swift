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
            VStack(alignment: .leading, spacing: 4) {
                Text(reservation.customerName)
                    .font(.headline)
                
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reservation.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var timeBadge: some View {
        Text(reservation.formattedTime)
            .font(.system(.body, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor)
            )
            .frame(width: 70)
    }
}
