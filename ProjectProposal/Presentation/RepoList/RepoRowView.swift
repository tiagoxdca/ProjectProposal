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
        RepoRowCard(fork: repo.fork) {
            HStack(alignment: .top, spacing: 12) {
                RepoRowIcon(fork: repo.fork)

                VStack(alignment: .leading, spacing: 8) {
                    RepoRowTitle(name: repo.name)
                    RepoRowDescription(text: repo.description)

                    RepoRowMetaChips(
                        fork: repo.fork,
                        ownerLogin: repo.ownerLogin,
                        language: nil,
                        stars: nil,
                        forks: nil
                    )
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(repo.name), by \(repo.ownerLogin)")
    }
}

// MARK: - Components

private struct RepoRowCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let fork: Bool?
    @ViewBuilder let content: Content

    init(fork: Bool?, @ViewBuilder content: () -> Content) {
        self.fork = fork
        self.content = content()
    }

    var body: some View {
        let (softColor, softRadius, softY) = RepoRowStyle.shadowSoft(colorScheme)
        let (crispColor, crispRadius, crispY) = RepoRowStyle.shadowCrisp(colorScheme)

        content
            .padding(.vertical, RepoRowStyle.verticalPadding)
            .padding(.horizontal, RepoRowStyle.horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: RepoRowStyle.cornerRadius, style: .continuous)
                    .fill(RepoRowStyle.cardFill(colorScheme))
                    .overlay {
                        RoundedRectangle(cornerRadius: RepoRowStyle.cornerRadius, style: .continuous)
                            .stroke(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.08)
                                    : Color.black.opacity(0.06),
                                lineWidth: 0.5
                            )
                    }
            }
            // Depth
            .shadow(color: softColor, radius: softRadius, x: 0, y: softY)
            .shadow(color: crispColor, radius: crispRadius, x: 0, y: crispY)
            .contentShape(RoundedRectangle(cornerRadius: RepoRowStyle.cornerRadius, style: .continuous))
    }
}

private struct RepoRowIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    let fork: Bool?

    var body: some View {
        let accent = RepoRowStyle.accent(for: fork)

        ZStack {
            Circle()
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay {
                    Circle().strokeBorder(.quaternary, lineWidth: 1)
                }

            Image(systemName: fork == true ? "tuningfork" : "shippingbox")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accent)
        }
        .frame(width: 34, height: 34)
        .accessibilityHidden(true)
    }
}

private struct RepoRowTitle: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.headline)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .contentTransition(.opacity)
    }
}

private struct RepoRowDescription: View {
    let text: String?

    var body: some View {
        if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .contentTransition(.opacity)
        }
    }
}

private struct RepoRowMetaChips: View {
    let fork: Bool?
    let ownerLogin: String

    // Prepared for option B (future data wiring)
    let language: String?
    let stars: Int?
    let forks: Int?

    var body: some View {
        HStack(spacing: 8) {
            RepoChip(
                systemImage: fork == true ? "tuningfork" : "sparkles",
                text: fork == true ? "Fork" : "Source"
            )

            RepoChip(systemImage: "person.fill", text: ownerLogin)

            if let language {
                RepoChip(systemImage: "chevron.left.forwardslash.chevron.right", text: language)
            }

            if let stars {
                RepoChip(systemImage: "star.fill", text: "\(stars)")
            }

            if let forks {
                RepoChip(systemImage: "arrow.triangle.branch", text: "\(forks)")
            }
        }
        .font(.caption)
    }
}

private struct RepoChip: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .imageScale(.small)
                .foregroundStyle(.secondary)

            Text(text)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(UIColor.tertiarySystemFill))
        .clipShape(Capsule())
    }
}
