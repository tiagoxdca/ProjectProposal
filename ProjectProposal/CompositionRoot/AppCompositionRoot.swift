//
//  AppCompositionRoot.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation
import SwiftData

final class AppCompositionRoot {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: CachedRepo.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
