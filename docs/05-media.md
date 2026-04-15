# 05 — Media (Photos, Upload, Cards)

## Documentation
- [PhotosUI / PhotosPicker](https://developer.apple.com/documentation/photokit/photospicker)
- [Spatie MediaLibrary](https://spatie.be/docs/laravel-medialibrary)

---

## PhotosPicker (iOS 16+)

```swift
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

    var body: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
            Label("Add Photos", systemImage: "photo")
        }
        .onChange(of: selectedItems) { items in
            Task { await loadImages(from: items) }
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var loaded: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loaded.append(image)
            }
        }
        images = loaded
    }
}
```

---

## Sending Photos via Multipart

```swift
// Convert UIImage → JPEG Data
let photoDatas: [Data] = images.compactMap {
    $0.jpegData(compressionQuality: 0.8)
}

// In Endpoint.multipart:
let files = photoDatas.enumerated().map { idx, data in
    MultipartFile(
        field: "photos[]",      // Laravel expects an array
        data: data,
        filename: "photo\(idx).jpg",
        mimeType: "image/jpeg"
    )
}
```

On the backend (Laravel):
```php
if ($request->hasFile('photos')) {
    foreach ($request->file('photos') as $photo) {
        $listing->addMedia($photo)
                ->toMediaCollection('listing-photos');
    }
}
```

---

## Spatie MediaLibrary — Setup

### Model

```php
class Listing extends Model implements HasMedia
{
    use InteractsWithMedia;

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('listing-photos')
             ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }

    public function registerMediaConversions(?Media $media = null): void
    {
        $this->addMediaConversion('thumb')
             ->width(400)->height(400)->format('webp')
             ->performOnCollections('listing-photos');

        $this->addMediaConversion('medium')
             ->width(800)->height(600)->format('webp')
             ->performOnCollections('listing-photos');
    }
}
```

### Resource

```php
'cover_url' => $this->whenLoaded('media', function () {
    return $this->getFirstMediaUrl('listing-photos') ?: null;
}),
'photos' => $this->whenLoaded('media', function () {
    return $this->getMedia('listing-photos')->map(fn($m) => [
        'id'        => $m->id,
        'url'       => $m->getUrl(),
        'thumb_url' => $m->getUrl('thumb') ?: $m->getUrl(),
    ]);
}),
```

> Don't forget `->with(['media'])` in queries, otherwise `whenLoaded` will return nothing.

---

## Photo Cards — Correct Pattern

### Problem

`AsyncImage` with `scaledToFit` produces cards of different heights.  
`AsyncImage` with `scaledToFill` + `.clipped()` — the photo overflows its bounds.

### Solution: Color as a Container

```swift
// Fixed container → overlay with AsyncImage → clipped
Color.gray.opacity(0.1)
    .frame(maxWidth: .infinity)
    .frame(height: 160)
    .overlay {
        AsyncImage(url: URL(string: listing.coverUrl ?? "")) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
    }
    .clipped()
    .clipShape(RoundedRectangle(cornerRadius: 12))
```

**Why this works:** `Color` always occupies exactly the specified `frame`. `AsyncImage` inside `overlay` renders within the same bounds. `.clipped()` trims everything that overflows the `frame`. The result — all cards have the same height regardless of photo aspect ratio.

---

## Media URL Normalization

If the backend runs locally on one IP and the app on another:

```php
// In ListingResource
private function normalizeMediaUrl(string $url): string
{
    $appUrl = rtrim(config('app.url'), '/');
    return preg_replace(
        '#https?://(localhost|192\.168\.\d+\.\d+)(:\d+)?#',
        $appUrl,
        $url
    );
}
```

---

## Updating Photos on Edit

```php
// Replace all photos if new ones are provided
if ($request->hasFile('photos')) {
    $listing->clearMediaCollection('listing-photos');
    foreach ($request->file('photos') as $photo) {
        $listing->addMedia($photo)->toMediaCollection('listing-photos');
    }
}
```
