//
//  ReservationEditorView.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI

/// View for creating or editing a reservation
struct ReservationEditorView: View {
    @State private var viewModel: ReservationEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(
        hairdresser: Hairdresser,
        date: Date,
        reservation: Reservation? = nil,
        dataStore: AppDataStore,
        onSave: @escaping () -> Void
    ) {
        _viewModel = State(
            wrappedValue: ReservationEditorViewModel(
                hairdresser: hairdresser,
                date: date,
                reservation: reservation,
                dataStore: dataStore,
                onSave: {
                    onSave()
                }
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Customer Information
                Section {
                    TextField(
                        NSLocalizedString("customer_name", comment: ""),
                        text: $viewModel.customerName
                    )
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    
                    TextField(
                        NSLocalizedString("phone_number", comment: ""),
                        text: $viewModel.phoneNumber
                    )
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                }
                
                // Time Selection
                Section(NSLocalizedString("select_time", comment: "")) {
                    Picker(NSLocalizedString("hour", comment: ""), selection: $viewModel.selectedHour) {
                        ForEach(viewModel.availableHours, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    
                    Picker(NSLocalizedString("minute", comment: ""), selection: $viewModel.selectedMinute) {
                        ForEach(viewModel.availableMinutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                }
                
                // Error Display
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Delete Button (only when editing)
                if viewModel.isEditing {
                    Section {
                        Button(role: .destructive) {
                            viewModel.confirmDelete()
                        } label: {
                            HStack {
                                Spacer()
                                Text(NSLocalizedString("delete_button", comment: ""))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel_button", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save_button", comment: "")) {
                        viewModel.save()
                    }
                    .disabled(viewModel.customerName.isEmpty || viewModel.phoneNumber.isEmpty)
                }
            }
            .alert(
                NSLocalizedString("conflict_title", comment: ""),
                isPresented: $viewModel.showingConflictAlert
            ) {
                Button(NSLocalizedString("ok_button", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("conflict_message", comment: ""))
            }
            .alert(
                NSLocalizedString("delete_confirmation_title", comment: ""),
                isPresented: $viewModel.showingDeleteConfirmation
            ) {
                Button(NSLocalizedString("cancel_button", comment: ""), role: .cancel) {}
                Button(NSLocalizedString("delete_button", comment: ""), role: .destructive) {
                    viewModel.delete()
                    dismiss()
                }
            } message: {
                Text(NSLocalizedString("delete_confirmation_message", comment: ""))
            }
        }
    }
}
