import SwiftUI

struct RepoListView: View {
    @State private var selectedRepo: Repo?
    @State private var showOpenDialog = false
    @State private var viewModel: RepoListViewModel

    @Environment(\.openURL) private var openURL

    let router: AppRouter

    init(viewModel: RepoListViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        RepoListScreen(
            state: viewModel.state,
            onRefresh: { @MainActor in
                await viewModel.refresh()
            },
            onLoadNextPageIfPossible: { @MainActor in
                await viewModel.loadNextPageIfPossible()
            },
            onTap: { repo in router.push(.repoDetails(repo)) },
            onLongPress: { repo in
                selectedRepo = repo
                showOpenDialog = true
            },
            onDismissError: { viewModel.dismissError() }
        )
        .navigationTitle("Apple Repos")
        .task(id: router.path.count) {
            await viewModel.onAppear()
        }
        .refreshable { await viewModel.refresh() }
        .confirmationDialog("Open in browser", isPresented: $showOpenDialog, titleVisibility: .visible) {
            if let repo = selectedRepo {
                Button("Open repository") { openURL(repo.repoURL) }
                Button("Open owner") { openURL(repo.ownerURL) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
