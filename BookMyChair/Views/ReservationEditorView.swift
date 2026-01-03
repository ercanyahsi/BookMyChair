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
    @State private var showingContactPicker = false
    
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
                    HStack {
                        TextField(
                            NSLocalizedString("customer_name", comment: ""),
                            text: $viewModel.customerName
                        )
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        
                        Button {
                            showingContactPicker = true
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                        .accessibilityLabel(NSLocalizedString("Select from contacts", comment: ""))
                    }
                    
                    TextField(
                        NSLocalizedString("phone_number", comment: ""),
                        text: $viewModel.phoneNumber
                    )
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                }
                
                // Time Selection
                Section {
                    HStack {
                        Text(NSLocalizedString("select_time", comment: ""))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Picker("", selection: $viewModel.selectedHour) {
                                ForEach(viewModel.availableHours, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            
                            Text(":")
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $viewModel.selectedMinute) {
                                ForEach(viewModel.availableMinutes, id: \.self) { minute in
                                    Text(String(format: "%02d", minute)).tag(minute)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        .font(.title3.monospacedDigit())
                    }
                } header: {
                    Text(NSLocalizedString("Appointment Time", comment: ""))
                }
                
                // Error Display
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.callout)
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
                
                if viewModel.isEditing {
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            viewModel.confirmDelete()
                        } label: {
                            Label(NSLocalizedString("delete_button", comment: ""), systemImage: "trash")
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save_button", comment: "")) {
                        viewModel.save()
                    }
                    .fontWeight(.semibold)
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
        .background(
            ContactPicker(isPresented: $showingContactPicker) { name, phone in
                viewModel.customerName = name
                viewModel.phoneNumber = phone
            }
        )
    }
}
