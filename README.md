# 📱 ProjectProposal — GitHub Repositories Explorer

[![iOS Unit Tests](https://github.com/tiagoxdca/ProjectProposal/actions/workflows/ci.yml/badge.svg)](https://github.com/tiagoxdca/ProjectProposal/actions/workflows/ci.yml)

An iOS application built as a **showcase of architecture, code quality, and best practices**, developed as part of the **Basecone iOS Coding Challenge**.

The app fetches and displays Apple’s public GitHub repositories, supporting pagination, caching, and a polished user experience.

---

## ✨ Features

- Fetches Apple’s public repositories from the GitHub API
- Endless scrolling with automatic pagination (10 repos per page)
- Persistent caching using **SwiftData**
- Cache-first strategy with silent refresh
- Skeleton loading & empty states
- Long-press actions to open:
  - Repository URL
  - Owner profile URL
- Visual distinction between forked and non-forked repositories
- Fully testable architecture with extensive unit test coverage

---

## 🧱 Architecture

The project follows a **Clean Architecture–inspired approach**, with clear separation of concerns:


```text
App
├─ Composition Root
│
├─ Presentation
│   └─ SwiftUI Views + ViewModels
│
├─ Domain
│   ├─ Entities
│   └─ Use Cases
│
└─ Data
    ├─ API
    ├─ Repository
    └─ Cache (SwiftData)
```


### Key principles applied
- Single Responsibility Principle (SRP)
- Dependency Inversion
- Explicit data flow
- Testability-first design

---

## 🧠 Presentation Layer

- Built with **SwiftUI**
- Uses a **ViewState-driven ViewModel** for predictable UI rendering
- ViewModel annotated with `@MainActor`
- State updates guarded to avoid unnecessary re-renders
- UI split into small, focused views:
  - Skeleton state
  - Empty state
  - Loaded content

---

## 🔄 Data Flow

1. ViewModel requests cached data → shown immediately if available
2. Silent refresh fetches latest data from the API
3. Results are persisted using SwiftData
4. Pagination loads next pages only when needed

This approach avoids UI flickering and provides a smooth user experience.

---

## 💾 Persistence

- Uses **SwiftData** for local caching
- Repositories are stored and updated via an abstract `RepoCacheStore`
- Cache is intentionally **not cleared on refresh** to prevent empty-state flicker

---

## 🌐 Networking

- Generic, reusable `HTTPClient` abstraction
- API client built around request builders
- GitHub pagination handled via the `Link` response header
- API layer is fully testable with stubs

---

## 🧪 Testing Strategy

The project includes **unit tests for all critical layers**, using **Swift Testing**, which provides modern syntax and first-class async/await support.

### Covered layers

- **Domain**
  - Use cases (`GetCachedRepos`, `RefreshRepos`, `LoadNextReposPage`)
- **Data**
  - Repository pagination & caching behavior
  - DTO → Domain mapping
  - HTTP `Link` header parsing
- **Presentation**
  - ViewModel state transitions
  - Cache-first behavior
  - Pagination loading states

### Testing decisions

- Concurrency-safe fakes implemented using `actor`
- Deterministic async tests using controlled delays
- Separate schemes for Unit Tests and UI Tests
- Unit tests can be run independently from UI tests

---

## ▶️ Running the App

1. Open `ProjectProposal.xcodeproj`
2. Select the scheme:
   - `ProjectProposal`
3. Choose an iOS Simulator
4. Press **Run**

---

## 🧪 Running Tests

### Unit Tests (recommended)

1. Select scheme: **ProjectProposal-UnitTests**
2. Destination: iOS Simulator
3. Press **Cmd + U**

### UI Tests (optional)

1. Select scheme: **ProjectProposal-UITests**
2. Press **Cmd + U**

---

## 📝 Notes & Decisions

- Swift Testing was chosen over XCTest for modern async support
- `Allow Testing Host Application APIs` is enabled to ensure reliable execution with Test Plans
- URLs are validated in the mapper to guarantee navigable links
- Architecture prioritizes clarity and scalability over premature modularization

Additional technical notes can be found in `notes.md`.

---

## 🚀 Possible Future Improvements

- GitHub authentication to avoid rate limits
- Search and filtering
- Offline-first indicators
- Snapshot UI tests

---

## 👤 Author

Developed by **Tiago Almeida**  
Senior iOS Developer  
GitHub: https://github.com/tiagoxdca
