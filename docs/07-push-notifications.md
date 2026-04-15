# 07 — Push Notifications (APNs)

## Documentation
- [UserNotifications](https://developer.apple.com/documentation/usernotifications)
- [Registering for Remote Notifications](https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications/setting-up-a-remote-notification-server)

---

## Xcode setup

1. **Signing & Capabilities** → `+ Capability` → **Push Notifications**
2. **Signing & Capabilities** → `+ Capability` → **Background Modes** → enable **Remote notifications**

The entitlement will be added automatically:
```xml
<key>aps-environment</key>
<string>development</string>   <!-- production for release builds -->
```

---

## iOS — registration and token retrieval

```swift
import UserNotifications

// In AppDelegate or @main App
func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
        guard granted else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

// Token received (AppDelegate)
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    // Send to backend
    Task { try await APIClient.shared.registerPushToken(token) }
}
```

### In SwiftUI @main

```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { RootView() }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Task { try? await APIClient.shared.registerPushToken(token) }
    }
}
```

---

## Backend — saving the token

```php
// device_tokens table
Schema::create('device_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('token')->unique();
    $table->string('platform')->default('ios'); // ios | android
    $table->timestamps();
});

// Endpoint
Route::post('device-tokens', [DeviceTokenController::class, 'store'])->middleware('auth:sanctum');

public function store(Request $request): JsonResponse
{
    $request->validate(['token' => 'required|string']);
    $request->user()->deviceTokens()->updateOrCreate(
        ['token' => $request->token],
        ['platform' => 'ios']
    );
    return response()->json(['message' => 'Token saved.']);
}
```

---

## Laravel — sending via APNs

### Installation

```bash
composer require laravel/vonage-notification-channel
# or use: edamov/pushok for direct APNs
# or: kutia-software-company/larafirebase for FCM
```

For direct APNs, the recommended package is `laravel-notification-channels/apn`:
```bash
composer require laravel-notification-channels/apn
```

### `.env` configuration

```
APN_KEY_ID=XXXXXXXXXX
APN_TEAM_ID=XXXXXXXXXX
APN_APP_BUNDLE_ID=com.company.myapp
APN_PRIVATE_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
APN_PRODUCTION=false
```

### Notification

```php
use NotificationChannels\Apn\ApnChannel;
use NotificationChannels\Apn\ApnMessage;

class NewMessageNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function via(object $notifiable): array
    {
        return [ApnChannel::class];
    }

    public function toApn(object $notifiable): ApnMessage
    {
        return ApnMessage::create()
            ->title('New message')
            ->body($this->message->body)
            ->custom('chat_id', $this->message->chat_id)
            ->custom('type', 'new_message');
    }
}
```

### Sending

```php
$user->notify(new NewMessageNotification($message));
// or via queue
$user->notifyNow(new NewMessageNotification($message));
```

---

## iOS — handling incoming notifications

```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Notification received while app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handler([.banner, .sound, .badge])
    }

    // User tapped a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler handler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let chatId = userInfo["chat_id"] as? Int {
            // Deep link into chat
            router.openChat(id: chatId)
        }
        handler()
    }
}
```

---

## Testing

Local testing via `Simulator` does not work — a physical device is required.

Quick test via `curl`:
```bash
# Get the token from the Xcode console
curl -X POST https://api.sandbox.push.apple.com/3/device/DEVICE_TOKEN \
  -H "apns-topic: com.company.myapp" \
  -H "apns-push-type: alert" \
  --data '{"aps":{"alert":{"title":"Test","body":"Hello"}}}' \
  --cert AuthKey.p8 \
  --http2
```
