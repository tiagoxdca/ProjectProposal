//
//  AppRouter.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 22/12/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path.removeAll()
    }
}
