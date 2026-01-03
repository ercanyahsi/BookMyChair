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
                        .font(.system(.body, design: .rounded))
                        
                        Button {
                            showingContactPicker = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(NSLocalizedString("Select from contacts", comment: ""))
                    }
                    
                    TextField(
                        NSLocalizedString("phone_number", comment: ""),
                        text: $viewModel.phoneNumber
                    )
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .font(.system(.body, design: .rounded))
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
                
                // Error Display with enhanced styling
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title3)
                                .foregroundStyle(.red)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 4)
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
                    .foregroundStyle(.secondary)
                }
                
                if viewModel.isEditing {
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            viewModel.confirmDelete()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(NSLocalizedString("delete_button", comment: ""))
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save_button", comment: "")) {
                        viewModel.save()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        viewModel.customerName.isEmpty || viewModel.phoneNumber.isEmpty
                            ? .secondary
                            : Color.accentColor
                    )
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
