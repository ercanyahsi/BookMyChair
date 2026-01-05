//
//  AboutView.swift
//  BookMyChair
//
//  Created on 05/01/2026.
//

import SwiftUI

/// About screen displaying app information
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon and Name
                    VStack(spacing: 16) {
                        Image(systemName: "chair.lounge.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
                        
                        Text("BookMyChair")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text(NSLocalizedString("about_version", comment: ""))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 30)
                    
                    // App Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("about_description_title", comment: ""))
                            .font(.headline)
                        
                        Text(NSLocalizedString("about_description_text", comment: ""))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text(NSLocalizedString("about_features_title", comment: ""))
                            .font(.headline)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            AboutFeatureRow(
                                icon: "person.2.fill",
                                title: NSLocalizedString("about_feature_hairdressers", comment: ""),
                                description: NSLocalizedString("about_feature_hairdressers_desc", comment: "")
                            )
                            
                            AboutFeatureRow(
                                icon: "calendar.badge.clock",
                                title: NSLocalizedString("about_feature_scheduling", comment: ""),
                                description: NSLocalizedString("about_feature_scheduling_desc", comment: "")
                            )
                            
                            AboutFeatureRow(
                                icon: "phone.fill",
                                title: NSLocalizedString("about_feature_contact", comment: ""),
                                description: NSLocalizedString("about_feature_contact_desc", comment: "")
                            )
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Donate Section (Placeholder)
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("about_support_title", comment: ""))
                            .font(.headline)
                        
                        Text(NSLocalizedString("about_support_text", comment: ""))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        // Placeholder for donate button
                        VStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.pink.gradient)
                            
                            Text(NSLocalizedString("about_donate_coming_soon", comment: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)
                    }
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Developer Info
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("about_developer", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("© 2026 BookMyChair")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(NSLocalizedString("about_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel_button", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Feature row component for the about screen
private struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    AboutView()
}
