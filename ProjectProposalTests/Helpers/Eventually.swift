//
//  Eventually.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing

@MainActor
func eventually(
    timeoutNanos: UInt64 = 1_000_000_000,   // 1s
    intervalNanos: UInt64 = 20_000_000,     // 20ms
    _ condition: @MainActor () -> Bool
) async {
    let start = DispatchTime.now().uptimeNanoseconds
    while !condition() {
        let now = DispatchTime.now().uptimeNanoseconds
        if now - start > timeoutNanos {
            #expect(condition(), "Condition not met before timeout")
            return
        }
        try? await Task.sleep(nanoseconds: intervalNanos)
    }
}
