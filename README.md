# ProjectProposal

iOS application developed as a showcase project for the Basecone iOS Coding Challenge.

The goal of this project is to demonstrate clean architecture, testable business logic, and modern iOS development practices using SwiftUI and SwiftData.

---

## Overview

The app fetches Apple's public GitHub repositories and displays them in an endless scrolling list.
Repositories are cached locally and updated transparently when new data is fetched from the network.

---

## Features

- Fetch public repositories from the GitHub API
- Endless scrolling with pagination (10 repositories per page)
- Persistent local cache using SwiftData
- Visual differentiation between forked and non-forked repositories
- Long-press actions to open repository or owner in the browser
- Pull-to-refresh support

---

## Tech Stack

- Swift 5.9+
- SwiftUI
- SwiftData
- Async/Await
- Clean Architecture (Domain / Data / Presentation)
- Dependency Injection via Composition Root and Factories
- No external dependencies

---

## Architecture

The project follows a layered architecture to ensure separation of concerns and testability:

- **Domain**
  - Business entities and use cases
  - Repository protocols (no framework dependencies)

- **Data**
  - GitHub API integration
  - SwiftData persistence
  - Repository implementations and mappers

- **Presentation**
  - SwiftUI views
  - View models responsible for UI state

- **App**
  - Composition root
  - Dependency graph setup

This structure allows easy replacement of infrastructure components and straightforward unit testing.

---

## Requirements

- iOS 17+
- Xcode 15+

---

## How to Run

1. Clone the repository
2. Open `ProjectProposal.xcodeproj`
3. Select an iOS 17+ simulator
4. Run the app

---

## Testing

Business logic is covered by unit tests.
Tests can be executed using:

- **Xcode** → `Cmd + U`

---

## Notes

Additional implementation details and architectural decisions can be found in `notes.md`.
