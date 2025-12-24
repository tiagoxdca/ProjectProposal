//
//  RepoListRows.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 24/12/2025.
//

import SwiftUI

struct RepoListRows: View {
    let repos: [Repo]
    let onTap: (Repo) -> Void
    let onLongPress: (Repo) -> Void

    var body: some View {
        ForEach(repos) { repo in
            RepoRowView(repo: repo)
                .contentShape(Rectangle())
                .onTapGesture { onTap(repo) }
                .onLongPressGesture { onLongPress(repo) }
                .padding(.horizontal, 12)
        }
    }
}
