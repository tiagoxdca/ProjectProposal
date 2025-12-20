//
//  RepoListSkeletonView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct RepoListSkeletonView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(0..<10, id: \.self) { _ in
                    RepoRowSkeletonView()
                        .padding(.horizontal, 12)
                }
            }
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
