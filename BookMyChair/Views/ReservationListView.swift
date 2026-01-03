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
            ForEach(viewModel.reservations, id: \.id) { reservation in
                ReservationRowView(reservation: reservation)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.editReservation(reservation)
                    }
            }
            .onDelete(perform: deleteReservations)
        }
        .listStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func deleteReservations(at offsets: IndexSet) {
        for index in offsets {
            let reservation = viewModel.reservations[index]
            viewModel.deleteReservation(reservation)
        }
    }
}
