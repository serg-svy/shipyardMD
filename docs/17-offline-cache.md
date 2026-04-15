# 17 — Offline & Cache

## Documentation
- [URLCache](https://developer.apple.com/documentation/foundation/urlcache)
- [Network framework](https://developer.apple.com/documentation/network)

---

## Strategy: Cache-first, Network-second

```swift
// Show cache instantly → update from network → refresh UI
func load() async {
    // 1. Show cached data immediately
    if let cached = CacheService.shared.get([Listing].self, key: "listings") {
        listings = cached
    }

    // 2. Load from network
    do {
        let result: Paginated<Listing> = try await api.request(
            ListingEndpoint.index(page: 1, filters: filters)
        )
        listings = result.data
        CacheService.shared.set(result.data, key: "listings", ttl: 300) // 5 min
    } catch let error as AppError {
        // No network — show cache silently
        if case .network = error, !listings.isEmpty { return }
        self.error = error
    }
}
```

---

## CacheService — in-memory with TTL

```swift
final class CacheService {
    static let shared = CacheService()
    private var store: [String: CacheEntry] = [:]

    struct CacheEntry {
        let data: Data
        let expiresAt: Date
    }

    func set<T: Encodable>(_ value: T, key: String, ttl: TimeInterval = 300) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        store[key] = CacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
    }

    func get<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let entry = store[key], entry.expiresAt > Date() else {
            store.removeValue(forKey: key)
            return nil
        }
        return try? JSONDecoder.api.decode(type, from: entry.data)
    }

    func invalidate(key: String) { store.removeValue(forKey: key) }
    func invalidateAll() { store.removeAll() }
}
```

---

## Network monitoring

```swift
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    @Published var isConnected = true

    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
}

// In View — "No internet" banner
.overlay(alignment: .top) {
    if !networkMonitor.isConnected {
        OfflineBanner()
    }
}
```

---

## URLSession cache for images

```swift
// Configure once at app launch
let cache = URLCache(
    memoryCapacity: 50 * 1024 * 1024,   // 50 MB in memory
    diskCapacity:  200 * 1024 * 1024,   // 200 MB on disk
    directory: nil
)
URLCache.shared = cache
```

`AsyncImage` automatically uses `URLCache.shared` — images are cached with no additional code.

---

## What to cache and what not to

| Data | Cache | TTL |
|---|---|---|
| Category list | Yes | 1 hour |
| Listings feed | Yes | 5 min |
| Listing details | Yes | 2 min |
| User profile | Yes | 5 min |
| Chat messages | No | — |
| OTP code | No | — |
| Payment data | No | — |
