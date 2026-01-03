//
//  ReservationListView.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI

/// Main view showing reservations for a selected hairdresser
struct ReservationListView: View {
    @State private var viewModel: ReservationListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(hairdresser: Hairdresser, dataStore: AppDataStore) {
        _viewModel = State(
            wrappedValue: ReservationListViewModel(
                hairdresser: hairdresser,
                dataStore: dataStore
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Picker
            datePicker
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            Divider()
            
            // Reservations List
            if viewModel.reservations.isEmpty {
                emptyStateView
            } else {
                reservationsList
            }
        }
        .navigationTitle(viewModel.hairdresser.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.addReservation()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 4, y: 2)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(NSLocalizedString("Add new reservation", comment: ""))
            }
        }
        .sheet(isPresented: $viewModel.showingEditor, onDismiss: {
            viewModel.loadReservations()
        }) {
            if let reservation = viewModel.editingReservation {
                ReservationEditorView(
                    hairdresser: viewModel.hairdresser,
                    date: viewModel.selectedDate,
                    reservation: reservation,
                    dataStore: viewModel.dataStore
                ) {
                    viewModel.showingEditor = false
                }
            } else {
                ReservationEditorView(
                    hairdresser: viewModel.hairdresser,
                    date: viewModel.selectedDate,
                    dataStore: viewModel.dataStore
                ) {
                    viewModel.showingEditor = false
                }
            }
        }
    }
    
    // MARK: - Date Picker
    
    private var datePicker: some View {
        VStack(spacing: 12) {
            // Date display with actual date
            VStack(spacing: 4) {
                Text(viewModel.dateDisplayTitle)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Text(viewModel.formattedDate)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            
            Picker("", selection: Binding(
                get: { viewModel.isShowingToday ? 0 : 1 },
                set: { newValue in
                    if newValue == 0 {
                        viewModel.showToday()
                    } else {
                        viewModel.showTomorrow()
                    }
                }
            )) {
                Text(NSLocalizedString("today", comment: "")).tag(0)
                Text(NSLocalizedString("tomorrow", comment: "")).tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.05), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.15),
                                Color.accentColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 32)
            
            VStack(spacing: 12) {
                Text(NSLocalizedString("no_reservations", comment: ""))
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text(viewModel.dateDisplayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)
            
            Button {
                viewModel.addReservation()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text(NSLocalizedString("add_reservation", comment: ""))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.accentColor.opacity(0.4), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.accentColor.opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Reservations List
    
    private var reservationsList: some View {
        List {
            ForEach(Array(viewModel.reservations.enumerated()), id: \.element.id) { index, reservation in
                ReservationRowView(
                    reservation: reservation,
                    status: getReservationStatus(reservation)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.editReservation(reservation)
                }
                .buttonStyle(.plain) // Prevent button from inheriting list row tap
            }
            .onDelete(perform: deleteReservations)
        }
        .listStyle(.plain)
    }
    
    // MARK: - Reservation Status
    
    private func getReservationStatus(_ reservation: Reservation) -> ReservationStatus {
        // Only apply status for today
        guard Calendar.current.isDateInToday(viewModel.selectedDate) else {
            return .upcoming
        }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        let reservationHour = reservation.timeSlot.hour
        let reservationMinute = reservation.timeSlot.minute
        
        // Check if this is the current/active reservation (within a reasonable window)
        // Consider an appointment "active" if we're within 30 minutes before to 30 minutes after
        let currentTotalMinutes = currentHour * 60 + currentMinute
        let reservationTotalMinutes = reservationHour * 60 + reservationMinute
        let difference = currentTotalMinutes - reservationTotalMinutes
        
        if difference >= 0 && difference < 30 {
            return .current
        } else if currentTotalMinutes < reservationTotalMinutes {
            return .upcoming
        } else {
            return .completed
        }
    }
    
    // MARK: - Actions
    
    private func deleteReservations(at offsets: IndexSet) {
        for index in offsets {
            let reservation = viewModel.reservations[index]
            viewModel.deleteReservation(reservation)
        }
    }
}
