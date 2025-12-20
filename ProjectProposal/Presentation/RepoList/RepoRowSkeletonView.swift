//
//  RepoRowSkeletonView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct RepoRowSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .frame(height: 16)
                .padding(.trailing, 80)

            RoundedRectangle(cornerRadius: 6)
                .frame(height: 14)
                .padding(.trailing, 30)

            RoundedRectangle(cornerRadius: 6)
                .frame(height: 12)
                .padding(.trailing, 160)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .redacted(reason: .placeholder)
        .shimmer()
    }
}
