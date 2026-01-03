//
//  HairdresserSelectionView.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI

/// Initial view for selecting or creating a hairdresser
struct HairdresserSelectionView: View {
    @State private var viewModel: HairdresserSelectionViewModel
    @State private var selectedHairdresser: Hairdresser?
    
    init(dataStore: AppDataStore) {
        _viewModel = State(wrappedValue: HairdresserSelectionViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hairdressers.isEmpty {
                    emptyStateView
                } else {
                    hairdresserListView
                }
            }
            .navigationTitle(NSLocalizedString("hairdresser_selection_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                createHairdresserSheet
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // App icon/logo representation
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "scissors.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 32)
            
            // Welcome message
            VStack(spacing: 12) {
                Text(NSLocalizedString("Welcome to BookMyChair", comment: ""))
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(NSLocalizedString("Manage your hairdressing appointments effortlessly", comment: ""))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 40)
            
            // Feature highlights
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "person.crop.circle.badge.plus",
                    title: NSLocalizedString("Add Hairdressers", comment: ""),
                    description: NSLocalizedString("Create profiles for each stylist", comment: "")
                )
                
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: NSLocalizedString("Schedule Appointments", comment: ""),
                    description: NSLocalizedString("Book and track daily reservations", comment: "")
                )
                
                FeatureRow(
                    icon: "phone.circle.fill",
                    title: NSLocalizedString("Quick Contact", comment: ""),
                    description: NSLocalizedString("Call customers with one tap", comment: "")
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            
            // Call to action
            Button {
                viewModel.showingCreateSheet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text(NSLocalizedString("Add Your First Hairdresser", comment: ""))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .shadow(color: Color.accentColor.opacity(0.3), radius: 10, y: 5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Hairdresser List
    
    private var hairdresserListView: some View {
        VStack(spacing: 0) {
            // Header info
            VStack(spacing: 8) {
                Text(NSLocalizedString("Select a hairdresser to view their schedule", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGroupedBackground))
            
            List {
                ForEach(viewModel.hairdressers, id: \.id) { hairdresser in
                    NavigationLink(value: hairdresser) {
                        HairdresserRowView(hairdresser: hairdresser)
                    }
                }
                .onDelete(perform: deleteHairdressers)
            }
            .listStyle(.plain)
        }
        .navigationDestination(for: Hairdresser.self) { hairdresser in
            ReservationListView(
                hairdresser: hairdresser,
                dataStore: viewModel.dataStore
            )
        }
    }
    
    // MARK: - Create Sheet
    
    private var createHairdresserSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        NSLocalizedString("hairdresser_name_placeholder", comment: ""),
                        text: $viewModel.newHairdresserName
                    )
                    .textContentType(.name)
                    .autocorrectionDisabled()
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("hairdresser_selection_create", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel_button", comment: "")) {
                        viewModel.showingCreateSheet = false
                        viewModel.resetCreateForm()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("create_button", comment: "")) {
                        viewModel.createHairdresser()
                    }
                    .disabled(viewModel.newHairdresserName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteHairdressers(at offsets: IndexSet) {
        for index in offsets {
            let hairdresser = viewModel.hairdressers[index]
            viewModel.deleteHairdresser(hairdresser)
        }
    }
}

// MARK: - Supporting Views

/// Feature row for empty state
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

/// Row view for displaying a hairdresser
struct HairdresserRowView: View {
    let hairdresser: Hairdresser
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hairdresser.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                    Text(NSLocalizedString("View Schedule", comment: ""))
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hairdresser.name)
        .accessibilityHint(NSLocalizedString("Tap to view schedule", comment: ""))
    }
}
