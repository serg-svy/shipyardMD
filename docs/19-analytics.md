# 19 — Analytics & Monitoring

## Documentation
- [Firebase Analytics](https://firebase.google.com/docs/analytics/get-started?platform=ios)
- [MetricKit](https://developer.apple.com/documentation/metrickit)

---

## Analytics layer — don't couple to a specific SDK

```swift
// Protocol — swap Firebase for Amplitude without changing any other code
protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
    func setUser(id: Int)
    func clearUser()
}

enum AnalyticsEvent {
    // Listings
    case listingViewed(id: Int, category: String)
    case listingCreated(category: String, price: Double)
    case listingFavorited(id: Int)
    case searchPerformed(query: String, resultsCount: Int)

    // Auth
    case signedIn(method: String)   // "otp", "apple", "google"
    case signedOut

    // Chat
    case chatOpened(listingId: Int)
    case messageSent(type: String)  // "text", "offer", "image"

    var name: String {
        switch self {
        case .listingViewed:    return "listing_viewed"
        case .listingCreated:   return "listing_created"
        case .listingFavorited: return "listing_favorited"
        case .searchPerformed:  return "search_performed"
        case .signedIn:         return "signed_in"
        case .signedOut:        return "signed_out"
        case .chatOpened:       return "chat_opened"
        case .messageSent:      return "message_sent"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .listingViewed(let id, let category):
            return ["listing_id": id, "category": category]
        case .listingCreated(let category, let price):
            return ["category": category, "price": price]
        case .searchPerformed(let query, let count):
            return ["query": query, "results_count": count]
        case .signedIn(let method):
            return ["method": method]
        case .messageSent(let type):
            return ["message_type": type]
        default:
            return [:]
        }
    }
}
```

### Firebase implementation

```swift
import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
    func setUser(id: Int) {
        Analytics.setUserID("\(id)")
    }
    func clearUser() {
        Analytics.setUserID(nil)
    }
}
```

### Usage

```swift
// In app init
let analytics: AnalyticsServiceProtocol = FirebaseAnalyticsService()

// In ViewModel
analytics.track(.listingViewed(id: listing.id, category: listing.category?.slug ?? ""))
```

---

## Crash Reporting — Firebase Crashlytics

```bash
# Install via SPM
# Package URL: https://github.com/firebase/firebase-ios-sdk
# Products: FirebaseCrashlytics, FirebaseAnalytics
```

```swift
// AppDelegate
import FirebaseCrashlytics

// Set userId after login — visible in Crashlytics
Crashlytics.crashlytics().setUserID("\(userId)")

// Log important events before a potential crash
Crashlytics.crashlytics().log("User opened listing \(listingId)")

// Record non-fatal errors
Crashlytics.crashlytics().record(error: error)
```

> **Important:** `GoogleService-Info.plist` — add to `.gitignore`! It contains project keys.

---

## App Store policy — what you cannot track

- Without explicit user consent: IDFA, cross-app tracking
- `AppTrackingTransparency` request is required if you use IDFA
- Firebase Analytics does not use IDFA by default — safe to use

---

## MetricKit — system performance (free from Apple)

```swift
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricsManager()

    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    // Called once per day
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            if let launch = payload.applicationLaunchMetrics {
                let time = launch.histogrammedTimeToFirstDraw.bucketEnumerator
                // Log launch time
            }
        }
    }
}
```
