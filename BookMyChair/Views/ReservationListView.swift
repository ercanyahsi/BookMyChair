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
                    Image(systemName: "plus")
                }
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
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("no_reservations", comment: ""))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(viewModel.dateDisplayTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                viewModel.addReservation()
            } label: {
                Label(
                    NSLocalizedString("add_reservation", comment: ""),
                    systemImage: "plus.circle.fill"
                )
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Reservations List
    
    private var reservationsList: some View {
        List {
            ForEach(Array(viewModel.reservations.enumerated()), id: \.element.id) { index, reservation in
                VStack(spacing: 0) {
                    // Show current time indicator if applicable
                    if shouldShowCurrentTimeIndicator(before: reservation, at: index) {
                        currentTimeIndicator
                    }
                    
                    ReservationRowView(reservation: reservation)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.editReservation(reservation)
                        }
                }
            }
            .onDelete(perform: deleteReservations)
            
            // Show current time indicator at the end if needed
            if shouldShowCurrentTimeIndicatorAtEnd() {
                currentTimeIndicator
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Current Time Indicator
    
    private var currentTimeIndicator: some View {
        HStack(spacing: 8) {
            Text(currentTimeString)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 2)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
    }
    
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    private func shouldShowCurrentTimeIndicator(before reservation: Reservation, at index: Int) -> Bool {
        // Only show for today
        guard Calendar.current.isDateInToday(viewModel.selectedDate) else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        let reservationHour = reservation.timeSlot.hour
        let reservationMinute = reservation.timeSlot.minute
        
        // Check if this is the first reservation
        if index == 0 {
            // Show indicator if current time is before first reservation
            if currentHour < reservationHour || (currentHour == reservationHour && currentMinute < reservationMinute) {
                return true
            }
        }
        
        // Check if current time is between previous and current reservation
        if index > 0 {
            let previousReservation = viewModel.reservations[index - 1]
            let prevHour = previousReservation.timeSlot.hour
            let prevMinute = previousReservation.timeSlot.minute
            
            let afterPrevious = currentHour > prevHour || (currentHour == prevHour && currentMinute >= prevMinute)
            let beforeCurrent = currentHour < reservationHour || (currentHour == reservationHour && currentMinute < reservationMinute)
            
            return afterPrevious && beforeCurrent
        }
        
        return false
    }
    
    private func shouldShowCurrentTimeIndicatorAtEnd() -> Bool {
        // Only show for today
        guard Calendar.current.isDateInToday(viewModel.selectedDate) else {
            return false
        }
        
        // Show at end if current time is after all reservations
        guard let lastReservation = viewModel.reservations.last else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        let lastHour = lastReservation.timeSlot.hour
        let lastMinute = lastReservation.timeSlot.minute
        
        return currentHour > lastHour || (currentHour == lastHour && currentMinute >= lastMinute)
    }
    
    // MARK: - Actions
    
    private func deleteReservations(at offsets: IndexSet) {
        for index in offsets {
            let reservation = viewModel.reservations[index]
            viewModel.deleteReservation(reservation)
        }
    }
}
