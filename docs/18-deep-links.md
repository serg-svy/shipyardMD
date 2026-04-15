# 18 — Deep Links & Universal Links

## Documentation
- [Supporting Universal Links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
- [Defining a custom URL scheme](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)

---

## Two types

| | URL Scheme | Universal Link |
|---|---|---|
| Format | `myapp://listing/42` | `https://myapp.com/listing/42` |
| Requires server | No | Yes (apple-app-site-association) |
| Opens browser if app not installed | No | Yes (fallback to website) |
| Apple recommendation | Deprecated | Preferred |

---

## Universal Links — setup

### 1. Entitlement

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:myapp.com</string>
</array>
```

In `project.yml`:
```yaml
entitlements:
  path: MyApp/MyApp.entitlements
  properties:
    com.apple.developer.associated-domains: ["applinks:myapp.com"]
```

### 2. File on the server

Create `https://myapp.com/.well-known/apple-app-site-association` (no extension):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.company.myapp",
        "paths": [
          "/listing/*",
          "/profile/*",
          "/chat/*"
        ]
      }
    ]
  }
}
```

### 3. Handling in the app

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    DeepLinkRouter.shared.handle(url)
                }
        }
    }
}
```

---

## DeepLinkRouter

```swift
@MainActor
final class DeepLinkRouter: ObservableObject {
    static let shared = DeepLinkRouter()

    @Published var pendingLink: DeepLink?

    enum DeepLink: Equatable {
        case listing(id: Int)
        case profile(id: Int)
        case chat(id: Int)
    }

    func handle(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let path = components.path.split(separator: "/").first else { return }

        let segments = components.path.split(separator: "/").map(String.init)

        switch segments.first {
        case "listing":
            if let id = segments.dropFirst().first.flatMap(Int.init) {
                pendingLink = .listing(id: id)
            }
        case "profile":
            if let id = segments.dropFirst().first.flatMap(Int.init) {
                pendingLink = .profile(id: id)
            }
        case "chat":
            if let id = segments.dropFirst().first.flatMap(Int.init) {
                pendingLink = .chat(id: id)
            }
        default: break
        }
    }
}
```

### Handling in RootView

```swift
struct RootView: View {
    @StateObject private var deepLink = DeepLinkRouter.shared
    @StateObject private var router = AppRouter()

    var body: some View {
        MainTabView()
            .onChange(of: deepLink.pendingLink) { link in
                guard let link else { return }
                switch link {
                case .listing(let id): router.openListing(id: id)
                case .profile(let id): router.openProfile(id: id)
                case .chat(let id):    router.openChat(id: id)
                }
                deepLink.pendingLink = nil
            }
    }
}
```

---

## Deep Link from Push Notification (cold start)

When the app was closed and the user tapped a notification:

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Check the notification that launched the app
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleNotificationPayload(notification)
        }
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Notification tapped (app running or in background)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler handler: @escaping () -> Void) {
        handleNotificationPayload(response.notification.request.content.userInfo)
        handler()
    }

    private func handleNotificationPayload(_ payload: [AnyHashable: Any]) {
        if let chatId = payload["chat_id"] as? Int {
            // Short delay to let the UI finish loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DeepLinkRouter.shared.pendingLink = .chat(id: chatId)
            }
        }
    }
}
```
