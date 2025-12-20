//
//  AppCompositionRoot.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftData

final class AppCompositionRoot {
    let container: ModelContainer
    let factory: AppFactory

    init() {
        do {
            container = try ModelContainer(for: CachedRepo.self)
            factory = DefaultAppFactory(container: container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
