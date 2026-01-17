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
            ZStack {
                // Decorative clock icon
                GeometryReader { geometry in
                    Image(systemName: "clock")
                        .font(.system(size: 250))
                        .foregroundStyle(Color.primary.opacity(0.05))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.7)
                        .rotationEffect(.degrees(-20))
                }
                .allowsHitTesting(false)
                
            Form {
                // Customer Information
                Section {
                    // Contact picker button - emphasized
                    Button {
                        showingContactPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 4, y: 2)
                                
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("Select from contacts", comment: ""))
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.accentColor)
                                
                                Text(NSLocalizedString("Recommended", comment: ""))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("Select from contacts", comment: ""))
                } header: {
                    Text(NSLocalizedString("Customer", comment: ""))
                }
                
                // Manual entry section
                Section {
                    TextField(
                        NSLocalizedString("customer_name", comment: ""),
                        text: $viewModel.customerName
                    )
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .rounded))
                    
                    TextField(
                        NSLocalizedString("phone_number", comment: ""),
                        text: $viewModel.phoneNumber
                    )
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .font(.system(.body, design: .rounded))
                } header: {
                    Text(NSLocalizedString("Or enter manually", comment: ""))
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
                    
                    HStack {
                        Text(NSLocalizedString("duration", comment: ""))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.selectedDuration) {
                            ForEach(viewModel.availableDurations, id: \.minutes) { duration in
                                Text(duration.label).tag(duration.minutes)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
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
                            Label(NSLocalizedString("delete_button", comment: ""), systemImage: "trash.fill")
                                .fontWeight(.semibold)
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
                        viewModel.customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        viewModel.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .secondary
                            : Color.accentColor
                    )
                    .disabled(
                        viewModel.customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        viewModel.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
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
