//
//  RepoRowView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct RepoRowView: View {
    let repo: Repo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(repo.name)
                .font(.headline)

            if let description = repo.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Text(repo.ownerLogin)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(RepoRowStyle.backgroundColor(for: repo.fork))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
