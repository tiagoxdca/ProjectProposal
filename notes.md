# Technical Notes — ProjectProposal

This document describes architectural decisions, trade-offs, and implementation details that were intentionally made during the development of this project.

The goal was not only to fulfill the requirements, but to build a codebase that would scale, remain testable, and be pleasant to maintain over time.

---

## Architecture Overview

The app follows a Clean Architecture–inspired structure, divided into four main layers:

- **Presentation** — SwiftUI views and ViewModels
- **Domain** — Entities and Use Cases (business rules)
- **Data** — API clients, repositories, cache stores
- **App** — Composition Root and dependency wiring

Each layer depends only on abstractions defined in inner layers.

---

## Composition Root & Dependency Injection

All dependencies are created in a single place using:

- `AppCompositionRoot`
- `AppFactory / DefaultAppFactory`

This approach:
- Makes dependencies explicit
- Avoids service locators or hidden singletons
- Keeps SwiftUI views free of construction logic
- Simplifies testing and future refactors

The factory methods responsible for creating ViewModels are isolated to the `MainActor`, since ViewModels themselves are `@MainActor`-isolated.

---

## Presentation Layer & ViewState

Instead of exposing multiple mutable properties (`isLoading`, `error`, `repos`), the ViewModel exposes a single:

```swift
enum RepoListViewState
