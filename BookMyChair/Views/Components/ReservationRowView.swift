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
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Time badge with status indicator and gradient
            timeBadge
            
            // Customer information
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(reservation.customerName)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(status == .completed ? .secondary : .primary)
                    
                    // NOW badge for current appointment with gradient
                    if status == .current {
                        Text("NOW")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.green.opacity(0.3), radius: 3, y: 1)
                    }
                    
                    // Checkmark for completed appointments
                    if status == .completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.green)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                
                Text(reservation.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .opacity(status == .completed ? 0.6 : 1.0)
            
            Spacer()
            
            // Call button with gradient and shadow
            Button {
                callCustomer()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.green.opacity(0.3), radius: 6, y: 3)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(NSLocalizedString("Call customer", comment: ""))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: status == .current 
                        ? Color.green.opacity(0.12)
                        : Color.black.opacity(0.04),
                    radius: status == .current ? 10 : 5,
                    y: status == .current ? 3 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    status == .current 
                        ? LinearGradient(
                            colors: [Color.green.opacity(0.4), Color.green.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: 2
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reservation.formattedTime), \(reservation.customerName)")
        .accessibilityHint(NSLocalizedString("Tap to edit reservation", comment: ""))
    }
    
    private var timeBadge: some View {
        Text(reservation.formattedTime)
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: status == .current 
                                ? [Color.green, Color.green.opacity(0.9)]
                                : status == .completed
                                    ? [Color.secondary.opacity(0.8), Color.secondary.opacity(0.6)]
                                    : [Color.accentColor, Color.accentColor.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(
                color: status == .current 
                    ? Color.green.opacity(0.3)
                    : status == .completed
                        ? Color.clear
                        : Color.accentColor.opacity(0.2),
                radius: 4,
                y: 2
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