# 02 — Architecture (MVVM + SwiftUI)

## Documentation
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [State and Data Flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)

---

## State Management — when to use what

| Property Wrapper | When to use |
|---|---|
| `@State` | Local view state (show sheet, toggle) |
| `@StateObject` | ViewModel created by the view itself |
| `@ObservedObject` | ViewModel passed in from outside |
| `@EnvironmentObject` | Global objects (AuthViewModel, Router) |
| `@Published` | Properties in ObservableObject that should update the UI |

### Rule:
- `@StateObject` — **owns** the object (creates it)
- `@ObservedObject` — **uses** the object (receives it from outside)
- Never create an `ObservableObject` inside `body` — use `@StateObject`

---

## ViewModel Structure

```swift
@MainActor
final class ListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIClient.shared

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            listings = try await api.request(ListingEndpoint.index(page: 1))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

> `@MainActor` guarantees that all `@Published` updates happen on the main thread.

---

## AppRouter — navigation

```swift
@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Tab = .home

    enum Tab { case home, search, sell, chats, profile }

    func push(_ destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

Register in `@main`:
```swift
@main
struct MyApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(router)
        }
    }
}
```

---

## NavigationStack

```swift
NavigationStack(path: $router.path) {
    HomeView()
        .navigationDestination(for: Listing.self) { listing in
            ListingDetailView(listing: listing)
        }
}
```

---

## Sheet management — important pattern

**Problem:** multiple `.sheet(isPresented:)` on the same view conflict in SwiftUI.

**Solution:** a single `.sheet(item:)` with an enum:

```swift
struct MyView: View {
    enum Sheet: Identifiable {
        case edit, share, map
        var id: Int { hashValue }
    }

    @State private var activeSheet: Sheet?

    var body: some View {
        VStack {
            Button("Edit") { activeSheet = .edit }
            Button("Map")  { activeSheet = .map }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .edit:  EditView()
            case .share: ShareView()
            case .map:   MapView()
            }
        }
    }
}
```

---

## TabView

```swift
TabView(selection: $router.selectedTab) {
    HomeView()
        .tabItem { Label("Home", systemImage: "house") }
        .tag(AppRouter.Tab.home)

    ProfileView()
        .tabItem { Label("Profile", systemImage: "person") }
        .tag(AppRouter.Tab.profile)
}
```

---

## Refresh via NotificationCenter

When you need to update one screen from another (e.g., refresh the feed after creating a listing):

```swift
// Sending
extension Notification.Name {
    static let listingCreated = Notification.Name("listingCreated")
}

NotificationCenter.default.post(name: .listingCreated, object: nil)

// Receiving
.onReceive(NotificationCenter.default.publisher(for: .listingCreated)) { _ in
    Task { await vm.load() }
}
```

---

## Pagination

```swift
func loadMoreIfNeeded(current item: Listing) async {
    guard listings.last?.id == item.id, hasMorePages, !isLoadingMore else { return }
    // load next page
}

// In the list:
ForEach(vm.listings) { listing in
    ListingCard(listing: listing)
        .task { await vm.loadMoreIfNeeded(current: listing) }
}
```
