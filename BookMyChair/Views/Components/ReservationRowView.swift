//
//  ReservationRowView.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI

/// Status of a reservation relative to current time
enum ReservationStatus {
    case completed  // Past appointment
    case current    // Currently active appointment
    case upcoming   // Future appointment
}

/// Component view for displaying a reservation in a list
struct ReservationRowView: View {
    let reservation: Reservation
    var status: ReservationStatus = .upcoming
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Time badge with status indicator
            timeBadge
            
            // Customer information
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(reservation.customerName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // NOW badge for current appointment
                    if status == .current {
                        Text("NOW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.green)
                            )
                    }
                    
                    // Checkmark for completed appointments
                    if status == .completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                Text(reservation.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .opacity(status == .completed ? 0.5 : 1.0)
            
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
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(status == .current ? Color.green.opacity(0.08) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(status == .current ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
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
                    .fill(status == .current ? Color.green : (status == .completed ? Color.secondary : Color.accentColor))
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