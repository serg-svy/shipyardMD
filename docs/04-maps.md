# 04 — Maps (MapKit + PostGIS)

## Documentation
- [MapKit](https://developer.apple.com/documentation/mapkit)
- [CoreLocation](https://developer.apple.com/documentation/corelocation)
- [CLGeocoder](https://developer.apple.com/documentation/corelocation/clgeocoder)

---

## Critical Issue: MKMapView Consumes Taps

`Map` in SwiftUI is a wrapper around `MKMapView` (UIKit). The UIKit component intercepts all gestures **before** SwiftUI, so:
- `Button { } label: { Map(...) }` — **does not work**
- `.onTapGesture` on `Map` — **does not work**
- `.disabled(true)` on `Map` — **does not work completely**

### Solution: Transparent Overlay

```swift
Map(coordinateRegion: .constant(region), annotationItems: pins) { pin in
    MapMarker(coordinate: pin.coordinate)
}
.frame(height: 160)
.overlay {
    Color.clear
        .contentShape(Rectangle())
        .onTapGesture { openFullMap() }  // ← this will work
}
.overlay(alignment: .bottomTrailing) {
    // "Open Map" label — allowsHitTesting(false) so taps pass through to the overlay above
    openMapLabel
        .allowsHitTesting(false)
}
```

---

## Static Map Preview (Snippet)

```swift
struct MapSnippet: View {
    let lat: Double
    let lng: Double

    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    var body: some View {
        Map(coordinateRegion: .constant(region),
            annotationItems: [MapPin(lat: lat, lng: lng)]) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .blue)
        }
        .allowsHitTesting(false)   // not .disabled(true)
    }
}
```

---

## User Geolocation

```swift
import CoreLocation

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var city: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func startUpdating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        location = loc
        geocodeCity(loc)
        manager.stopUpdatingLocation()
    }

    private func geocodeCity(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                self?.city = placemarks?.first?.locality
            }
        }
    }
}
```

### Important: ZIP → City

If the user enters a ZIP code, it needs to be geocoded into a city name:

```swift
// MKLocalSearchCompleter returns "33334, Fort Lauderdale, FL"
// Need forward-geocode to get locality

CLGeocoder().geocodeAddressString(completionTitle) { placemarks, _ in
    let city = placemarks?.first?.locality ?? completionTitle
    // Save city, not ZIP
}
```

---

## PostGIS on Backend (Laravel)

### Writing Coordinates

```php
// CORRECT
DB::statement(
    'UPDATE listings SET location = ST_SetSRID(ST_MakePoint(?, ?), 4326) WHERE id = ?',
    [$lng, $lat, $this->id]   // order: lng, lat (not lat, lng!)
);

// INCORRECT — "geometry/geography mismatch" error
DB::statement('UPDATE listings SET location = ST_MakePoint(?, ?)::geography WHERE id = ?', ...);
```

### Reading Coordinates

```php
// In the Listing model
public function getGeoJson(): ?array
{
    $result = DB::selectOne(
        'SELECT ST_Y(location) as lat, ST_X(location) as lng FROM listings WHERE id = ? AND location IS NOT NULL',
        [$this->id]
    );
    if (!$result) return null;
    return ['lat' => (float)$result->lat, 'lng' => (float)$result->lng];
}
```

### Nearby Search

```php
public function scopeNearby($query, float $lat, float $lng, int $radiusKm = 25)
{
    return $query->whereRaw(
        'ST_DWithin(location::geography, ST_MakePoint(?, ?)::geography, ?)',
        [$lng, $lat, $radiusKm * 1000]
    );
}
```

### Migration

```php
$table->geography('location', 'point', 4326)->nullable();
// or
DB::statement('ALTER TABLE listings ADD COLUMN location geometry(Point, 4326)');
DB::statement('CREATE INDEX listings_location_idx ON listings USING GIST(location)');
```

---

## Map with Annotations and Carousel

Pattern: `MapListingsView` + bottom carousel with `TabView(.page)`:

```swift
TabView(selection: $currentIndex) {
    ForEach(Array(annotations.enumerated()), id: \.offset) { idx, annotation in
        ListingCard(listing: annotation.listing)
            .tag(idx)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
.frame(height: 120)
.onChange(of: currentIndex) { idx in
    // Move the map to the selected card
    region.center = annotations[idx].coordinate
}
```

---

## "Open in Maps"

```swift
let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
let placemark = MKPlacemark(coordinate: coordinate)
let item = MKMapItem(placemark: placemark)
item.name = title
item.openInMaps(launchOptions: [MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue])
```
