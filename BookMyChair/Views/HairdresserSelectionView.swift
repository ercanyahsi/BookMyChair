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
    @State private var hairdresserToDelete: Hairdresser?
    @State private var showingDeleteAlert = false
    @State private var showingAbout = false
    
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18))
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingCreateSheet = true
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
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                createHairdresserSheet
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert(
                NSLocalizedString("delete_hairdresser_title", comment: ""),
                isPresented: $showingDeleteAlert,
                presenting: hairdresserToDelete
            ) { hairdresser in
                Button(NSLocalizedString("cancel_button", comment: ""), role: .cancel) {
                    hairdresserToDelete = nil
                }
                Button(NSLocalizedString("delete_button", comment: ""), role: .destructive) {
                    viewModel.deleteHairdresser(hairdresser)
                    hairdresserToDelete = nil
                }
            } message: { hairdresser in
                Text(String(format: NSLocalizedString("delete_hairdresser_message", comment: ""), hairdresser.name))
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        ZStack {
            // Background gradient layers
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.03),
                    Color.clear,
                    Color.accentColor.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Large decorative scissors icon
            GeometryReader { geometry in
                Image(systemName: "scissors")
                    .font(.system(size: 280))
                    .foregroundStyle(Color.primary.opacity(0.06))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                    .rotationEffect(.degrees(-25))
            }
            .allowsHitTesting(false)
            
            // Decorative circles
            GeometryReader { geometry in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.06), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geometry.size.width * 0.7, y: -100)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.04), Color.clear],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: -50, y: geometry.size.height * 0.6)
            }
            
            VStack(spacing: 0) {
                Spacer()
            
            // App icon with gradient and animation
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
                    .frame(width: 140, height: 140)
                    .blur(radius: 15)
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 130, height: 130)
                    .shadow(color: Color.accentColor.opacity(0.2), radius: 20, y: 10)
                
                Image(systemName: "scissors.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 40)
            
            // Welcome message with enhanced typography
            VStack(spacing: 14) {
                Text(NSLocalizedString("Welcome to BookMyChair", comment: ""))
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                
                Text(NSLocalizedString("Manage your hairdressing appointments effortlessly", comment: ""))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(2)
            }
            .padding(.bottom, 48)
            
            // Feature highlights with enhanced design
            VStack(alignment: .leading, spacing: 24) {
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
            .padding(.bottom, 48)
            
            // Call to action with gradient button
            Button {
                viewModel.showingCreateSheet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text(NSLocalizedString("Add Your First Hairdresser", comment: ""))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.accentColor.opacity(0.4), radius: 15, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            
            Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Hairdresser List
    
    private var hairdresserListView: some View {
        ZStack {
            // Decorative scissors icon for list view
            GeometryReader { geometry in
                Image(systemName: "scissors")
                    .font(.system(size: 200))
                    .foregroundStyle(Color.primary.opacity(0.05))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
                    .rotationEffect(.degrees(20))
            }
            .allowsHitTesting(false)
            
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
        guard let index = offsets.first else { return }
        hairdresserToDelete = viewModel.hairdressers[index]
        showingDeleteAlert = true
    }
}

// MARK: - Supporting Views

/// Feature row for empty state with enhanced design
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 18) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.12),
                                Color.accentColor.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

/// Row view for displaying a hairdresser with enhanced visual design
struct HairdresserRowView: View {
    let hairdresser: Hairdresser
    
    var body: some View {
        HStack(spacing: 18) {
            // Avatar circle with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.2),
                                Color.accentColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.accentColor.opacity(0.15), radius: 8, y: 3)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(hairdresser.name)
                    .font(.system(.body, design: .rounded))
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
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hairdresser.name)
        .accessibilityHint(NSLocalizedString("Tap to view schedule", comment: ""))
    }
}
