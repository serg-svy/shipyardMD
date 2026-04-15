# 15 — Clean Architecture & Code Quality

---

## Principle: modules don't know about each other

```
┌─────────────────────────────────────────┐
│              Features/                  │
│  ┌─────────┐  ┌──────────┐  ┌───────┐  │
│  │  Auth   │  │ Listings │  │ Chat  │  │
│  └────┬────┘  └────┬─────┘  └───┬───┘  │
│       │            │             │      │
└───────┼────────────┼─────────────┼──────┘
        │            │             │
┌───────▼────────────▼─────────────▼──────┐
│                 Core/                   │
│  Network │ DesignSystem │ Extensions    │
└─────────────────────────────────────────┘
```

**Rules:**
- `Features/Listings` does not import `Features/Chat`
- Everything shared — only through `Core/`
- Dependencies always flow downward, never upward

---

## Dependency Injection — no singletons in business logic

**Bad — hardcoded dependency, cannot be tested:**
```swift
final class ListingsViewModel: ObservableObject {
    private let api = APIClient.shared   // ← tight coupling
}
```

**Good — injection via protocol:**
```swift
final class ListingsViewModel: ObservableObject {
    private let api: APIClientProtocol   // ← can be replaced with a mock

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }
}

// In production — real implementation
let vm = ListingsViewModel()

// In tests — mock
let vm = ListingsViewModel(api: MockAPIClient())
```

### Protocols for all services

```swift
// Each service — protocol + implementation + mock
protocol LocationServiceProtocol {
    var city: String? { get }
    var location: CLLocation? { get }
    func startUpdating()
}

protocol KeychainServiceProtocol {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
    func requestVoid(_ endpoint: any Endpoint) async throws
}
```

---

## Application Layers

```
View                — UI only, no logic
  ↓ calls
ViewModel           — screen state, coordination
  ↓ calls
Service / UseCase   — business logic (optional for complex flows)
  ↓ calls
Repository          — data access (API, DB, cache)
  ↓ calls
APIClient           — HTTP requests
```

**View doesn't know about the API. ViewModel doesn't know about URLSession.**

### Example with UseCase (for complex logic)

```swift
// Simple screen — ViewModel calls API directly. OK.
// Complex flow (create listing with photos + geolocation + categories) — UseCase

protocol CreateListingUseCaseProtocol {
    func execute(draft: ListingDraft) async throws -> Listing
}

final class CreateListingUseCase: CreateListingUseCaseProtocol {
    private let api: APIClientProtocol
    private let location: LocationServiceProtocol

    init(api: APIClientProtocol = APIClient.shared,
         location: LocationServiceProtocol = LocationService.shared) {
        self.api = api
        self.location = location
    }

    func execute(draft: ListingDraft) async throws -> Listing {
        var draft = draft
        // Enrich with data from services
        if draft.lat == nil, let loc = location.location {
            draft.lat = loc.coordinate.latitude
            draft.lng = loc.coordinate.longitude
        }
        return try await api.request(ListingEndpoint.store(draft: draft))
    }
}
```

---

## ViewModel — rules

### One screen — one ViewModel

```swift
// DO NOT create one giant ViewModel for the whole app
// Each screen/feature — its own @MainActor ViewModel

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing
    @Published var isFavorite = false
    @Published var isLoading = false
    @Published var error: AppError?

    private let api: APIClientProtocol

    init(listing: Listing, api: APIClientProtocol = APIClient.shared) {
        self.listing = listing
        self.api = api
    }
}
```

### When to split a ViewModel

Split when a ViewModel is doing more than one thing:
```
ListingsViewModel      — loading the feed, pagination, filters
ListingDetailViewModel — details, favorites, view count
CreateListingViewModel — creation form, photos, geolocation
```

### Cancellation — cancel tasks when leaving the screen

```swift
@MainActor
final class ListingsViewModel: ObservableObject {
    private var loadTask: Task<Void, Never>?

    func load() {
        loadTask?.cancel()
        loadTask = Task {
            isLoading = true
            defer { isLoading = false }
            guard !Task.isCancelled else { return }
            // ...
        }
    }

    // Call on .onDisappear
    func cancelAll() {
        loadTask?.cancel()
    }
}
```

---

## Error Handling — unified strategy

### Error types

```swift
enum AppError: LocalizedError {
    case network(URLError)              // no internet
    case unauthorized                   // 401 — log out
    case notFound                       // 404
    case validation([String: [String]]) // 422 — form errors
    case server(Int)                    // 5xx
    case decoding(Error)               // parsing error
    case unknown

    var errorDescription: String? {
        switch self {
        case .network:        return String(localized: "error.no_internet")
        case .unauthorized:   return String(localized: "error.unauthorized")
        case .notFound:       return String(localized: "error.not_found")
        case .validation(let errors):
            return errors.values.flatMap { $0 }.first
        case .server(let code): return String(format: String(localized: "error.server"), code)
        case .decoding:       return String(localized: "error.decoding")
        case .unknown:        return String(localized: "error.unknown")
        }
    }

    // Should we log out?
    var requiresLogout: Bool { self == .unauthorized }
}
```

### APIClient parses errors centrally

```swift
private func parseError(statusCode: Int, data: Data) -> AppError {
    switch statusCode {
    case 401: return .unauthorized
    case 404: return .notFound
    case 422:
        if let body = try? JSONDecoder().decode(ValidationError.self, from: data) {
            return .validation(body.errors)
        }
        return .unknown
    case 500...: return .server(statusCode)
    default:     return .unknown
    }
}
```

### ViewModel handles errors

```swift
do {
    listings = try await api.request(ListingEndpoint.index(page: 1, filters: filters))
} catch let error as AppError {
    if error.requiresLogout {
        // Global signal — log out
        NotificationCenter.default.post(name: .unauthorized, object: nil)
    } else {
        self.error = error
    }
} catch {
    self.error = .unknown
}
```

### View displays errors consistently

```swift
// Reusable component
struct ErrorBanner: View {
    let error: AppError
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(error.localizedDescription)
                .font(.dhBody)
                .multilineTextAlignment(.center)
            if let onRetry {
                Button("Retry", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(Spacing.md)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
```

---

## Parallel requests

```swift
// Load multiple resources simultaneously
func loadDetail() async throws {
    async let listing = api.request(ListingEndpoint.show(id: id))
    async let seller  = api.request(UserEndpoint.show(id: sellerId))

    // Wait for both — in parallel
    let (l, s) = try await (listing, seller)
    self.listing = l
    self.seller = s
}
```

---

## Retry logic with timeout

```swift
extension APIClientProtocol {
    func requestWithRetry<T: Decodable>(
        _ endpoint: any Endpoint,
        retries: Int = 3
    ) async throws -> T {
        var attempt = 0
        while true {
            do {
                return try await request(endpoint)
            } catch let error as AppError {
                attempt += 1
                guard attempt < retries,
                      case .server = error else { throw error }
                // Exponential backoff: 1s, 2s, 4s
                try await Task.sleep(for: .seconds(pow(2.0, Double(attempt - 1))))
            }
        }
    }
}
```

---

## Logging

```swift
import OSLog

extension Logger {
    static let network  = Logger(subsystem: "com.company.myapp", category: "Network")
    static let auth     = Logger(subsystem: "com.company.myapp", category: "Auth")
    static let listings = Logger(subsystem: "com.company.myapp", category: "Listings")
}

// Usage
Logger.network.info("→ GET \(endpoint.path)")
Logger.network.error("← \(statusCode) \(endpoint.path): \(error)")

// In production logs are visible only via Console.app — not in the code
// DO NOT use print() — it is not filtered or categorized
```

---

## Naming Conventions

```swift
// ViewModels — ViewModel suffix
ListingsViewModel, ListingDetailViewModel, AuthViewModel

// Views — View suffix
ListingsView, ListingDetailView, AuthView

// Services — Service suffix
LocationService, KeychainService, NotificationService

// Protocols — Protocol suffix
APIClientProtocol, LocationServiceProtocol

// Use Cases — UseCase suffix
CreateListingUseCase, SendOtpUseCase

// Endpoints — Endpoint suffix (enum)
ListingEndpoint, AuthEndpoint, UserEndpoint

// Resources (Laravel) — Resource suffix
ListingResource, UserResource, CategoryResource
```

---

## File structure — one file per type

```
Features/Listings/
├── Views/
│   ├── ListingsView.swift           # one screen — one file
│   ├── ListingDetailView.swift
│   └── Components/                  # reusable within the feature
│       ├── ListingMapSnippet.swift
│       └── SellerRow.swift
├── ViewModels/
│   ├── ListingsViewModel.swift
│   └── ListingDetailViewModel.swift
└── Services/                        # feature-specific
    └── ListingDraftService.swift
```

**Rule:** if a component is used in 2+ features → move it to `Core/DesignSystem/`.

---

## File and function size

- File > 300 lines → it's probably doing too much, split it
- Function > 30 lines → extract logic into a private method or UseCase
- Nesting > 3 levels → simplify via guard, return early

```swift
// Bad — deep nesting
func process() {
    if let user = user {
        if let token = token {
            if !isExpired {
                doSomething()
            }
        }
    }
}

// Good — early return
func process() {
    guard let user  = user  else { return }
    guard let token = token else { return }
    guard !isExpired        else { return }
    doSomething()
}
```

---

## Memory Management

Always use `[weak self]` in closures that are stored:

```swift
// Bad — retain cycle
locationManager.onUpdate = {
    self.city = "Miami"   // self holds locationManager, locationManager holds self
}

// Good
locationManager.onUpdate = { [weak self] in
    self?.city = "Miami"
}

// In async — not needed if the Task lives together with self
Task { [weak self] in
    await self?.load()
}
```

---

## SwiftLint — automated quality control

Add to the project:
```bash
brew install swiftlint
```

`.swiftlint.yml` at the root of ios/:
```yaml
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - explicit_init
  - closure_spacing
  - operator_usage_whitespace

line_length: 120
file_length: 300
function_body_length: 40

excluded:
  - Pods
  - DerivedData
```

Add to `project.yml` as a Build Phase:
```yaml
targets:
  MyApp:
    preBuildScripts:
      - script: |
          if which swiftlint > /dev/null; then
            swiftlint
          fi
        name: SwiftLint
```

---

## Final dependency structure

```
PostListingView
    └── CreateListingViewModel(api: APIClientProtocol, location: LocationServiceProtocol)
            └── CreateListingUseCase
                    ├── APIClient: APIClientProtocol  ← real or mock
                    └── LocationService: LocationServiceProtocol  ← real or mock

// In tests we inject:
CreateListingViewModel(api: MockAPIClient(), location: MockLocationService())
```
