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
        VStack(spacing: 20) {
            Image(systemName: "scissors")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .symbolRenderingMode(.hierarchical)
            
            Text(NSLocalizedString("hairdresser_selection_title", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.showingCreateSheet = true
            } label: {
                Label(
                    NSLocalizedString("hairdresser_selection_create", comment: ""),
                    systemImage: "plus.circle.fill"
                )
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Hairdresser List
    
    private var hairdresserListView: some View {
        List {
            ForEach(viewModel.hairdressers, id: \.id) { hairdresser in
                NavigationLink(value: hairdresser) {
                    HairdresserRowView(hairdresser: hairdresser)
                }
            }
            .onDelete(perform: deleteHairdressers)
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

/// Row view for displaying a hairdresser
struct HairdresserRowView: View {
    let hairdresser: Hairdresser
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
            
            Text(hairdresser.name)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hairdresser.name)
    }
}
