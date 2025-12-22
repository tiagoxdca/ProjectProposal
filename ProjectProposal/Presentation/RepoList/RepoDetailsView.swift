//
//  RepoDetailsView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 22/12/2025.
//

import SwiftUI

struct RepoDetailsView: View {
    let repo: Repo
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            headerSection
            descriptionSection
            linksSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(repo.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                avatar

                VStack(alignment: .leading, spacing: 6) {
                    Text(repo.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)

                    Text(repo.ownerLogin)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    forkBadge
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    private var descriptionSection: some View {
        Section("Description") {
            if let desc = repo.description, !desc.isEmpty {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("No description available.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var linksSection: some View {
        Section("Links") {
            Button {
                openURL(repo.repoURL)
            } label: {
                Label("Open repository", systemImage: "link")
            }

            Button {
                openURL(repo.ownerURL)
            } label: {
                Label("Open owner profile", systemImage: "person.crop.circle")
            }
        }
    }

    // MARK: - Small UI pieces

    private var forkBadge: some View {
        let isFork = repo.fork ?? false
        return Text(isFork ? "Fork" : "Original")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isFork ? Color(.systemGray5) : Color.green.opacity(0.18))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
            .accessibilityLabel(isFork ? "Fork repository" : "Original repository")
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 44, height: 44)

            Image(systemName: "shippingbox")
                .foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Repo Details") {
    NavigationStack {
        RepoDetailsView(
            repo: Repo(
                id: 1,
                name: "swift",
                description: "The Swift Programming Language",
                fork: false,
                repoURL: URL(string: "https://github.com/apple/swift")!,
                ownerLogin: "apple",
                ownerURL: URL(string: "https://github.com/apple")!
            )
        )
    }
}
