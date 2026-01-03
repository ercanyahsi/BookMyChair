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
            // Date Toggle
            dateToggle
            
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
    
    // MARK: - Date Toggle
    
    private var dateToggle: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.showToday()
            } label: {
                Text(NSLocalizedString("today", comment: ""))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.isShowingToday ? Color.accentColor : Color.clear)
                    .foregroundColor(viewModel.isShowingToday ? .white : .primary)
            }
            
            Divider()
            
            Button {
                viewModel.showTomorrow()
            } label: {
                Text(NSLocalizedString("tomorrow", comment: ""))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.isShowingTomorrow ? Color.accentColor : Color.clear)
                    .foregroundColor(viewModel.isShowingTomorrow ? .white : .primary)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("no_reservations", comment: ""))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                viewModel.addReservation()
            } label: {
                Label(
                    NSLocalizedString("add_reservation", comment: ""),
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(.borderedProminent)
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
