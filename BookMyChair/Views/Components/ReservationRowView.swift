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
            
            // Call button
            Button {
                callCustomer()
            } label: {
                Image(systemName: "phone.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.green)
                    )
            }
            .accessibilityLabel(NSLocalizedString("Call customer", comment: ""))
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
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor)
            )
            .frame(minWidth: 75)
    }
    
    // MARK: - Actions
    
    private func callCustomer() {
        // Clean phone number (remove spaces, dashes, etc.)
        let cleanedNumber = reservation.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let url = URL(string: "tel://\(cleanedNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}