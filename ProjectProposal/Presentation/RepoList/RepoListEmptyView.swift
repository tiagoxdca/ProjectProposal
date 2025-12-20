//
//  RepoListEmptyView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct RepoListEmptyView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            
            Text("No repositories yet")
                .font(.headline)
            
            Text("Pull to refresh or try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Refresh", action: onRefresh)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
