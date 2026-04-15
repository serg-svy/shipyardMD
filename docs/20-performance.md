# 20 — Performance

## Documentation
- [Instruments](https://developer.apple.com/documentation/xcode/instruments)
- [Analysing HTTP traffic](https://developer.apple.com/documentation/xcode/analysing-http-traffic-with-instruments)

---

## iOS — what to profile

### Instruments — launching
`Xcode → Product → Profile (Cmd+I)` → choose a template:
- **Time Profiler** — UI slowdowns and freezes
- **Allocations** — memory leaks
- **Network** — slow requests
- **SwiftUI** — view re-renders

### Main rule — nothing heavy on the Main Thread

```swift
// Bad — JSON parsing on the main thread
DispatchQueue.main.async {
    let data = try! JSONDecoder().decode([Listing].self, from: data) // blocks UI
    self.listings = data
}

// Good — async/await does not block the UI automatically
let result: [Listing] = try await api.request(ListingEndpoint.index(page: 1, filters: .empty))
// @MainActor ensures the assignment happens on the main thread
self.listings = result
```

### Avoid unnecessary SwiftUI re-renders

```swift
// Bad — the entire List re-renders on any change
struct ListingsView: View {
    @ObservedObject var vm: ListingsViewModel
    var body: some View {
        List(vm.listings) { listing in
            ListingCard(listing: listing)  // re-renders when vm.isLoading = true
        }
    }
}

// Good — split into subviews with clear dependencies
struct ListingCard: View {
    let listing: Listing    // no @State — only re-renders when listing changes
}
```

### LazyVStack instead of VStack for long lists

```swift
ScrollView {
    LazyVStack(spacing: Spacing.sm) {  // renders only visible items
        ForEach(listings) { listing in
            ListingCard(listing: listing)
        }
    }
}
```

---

## Backend — N+1 queries (the most common problem)

### The problem

```php
// N+1 — makes 21 database queries for 20 listings
$listings = Listing::all();
foreach ($listings as $listing) {
    echo $listing->user->name;   // a new query every iteration
}
```

### Solution — eager loading

```php
// 1 query for listings + 1 query for users = 2 queries total
$listings = Listing::with(['user:id,name,avatar_url', 'media', 'category'])->get();
```

### Laravel Debugbar — see all queries locally

```bash
composer require barryvdh/laravel-debugbar --dev
```

Adds a panel showing the number of SQL queries and their execution time. Always enable in dev.

### Database indexes — mandatory

```php
// In migration — add indexes on columns used for filtering/sorting
Schema::table('listings', function (Blueprint $table) {
    $table->index('status');
    $table->index('user_id');
    $table->index('category_id');
    $table->index('city');
    $table->index(['status', 'created_at']); // composite — for sorting active listings
    // PostGIS spatial index
    // DB::statement('CREATE INDEX listings_location_idx ON listings USING GIST(location)');
});
```

### Check for slow queries

```bash
# PostgreSQL — queries slower than 100ms
docker exec myapp_postgres psql -U myapp -d myapp -c "
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;"
```

---

## Pagination — always, everywhere

```php
// Never return all records
$listings = Listing::paginate(20);   // not all()

// Cursor pagination — faster for large tables
$listings = Listing::cursorPaginate(20);
```

---

## Images — optimization

```php
// Spatie — convert to WebP, set dimensions
$this->addMediaConversion('thumb')
     ->width(400)->height(400)
     ->format('webp')              // WebP is 2-3x smaller than JPEG
     ->quality(80)
     ->performOnCollections('listing-photos');
```

```swift
// iOS — request the size you need, not the original
// In cards — thumb_url (400px)
// In detail view — medium_url (800px)
// In gallery — url (original)
AsyncImage(url: URL(string: listing.photos?.first?.thumbUrl ?? listing.coverUrl ?? ""))
```

---

## Target metrics

| Metric | Goal |
|---|---|
| App launch time | < 2 sec |
| API response time | < 300ms |
| Pagination page size | 20-30 items |
| Thumbnail image size | < 50 KB |
| Scroll FPS | 60 fps |
| IPA file size | < 50 MB |
