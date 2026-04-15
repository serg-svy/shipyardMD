# 01 — Project Setup

> **Xcode version:** 26.4 (17E192)

## Documentation
- [Xcode overview](https://developer.apple.com/documentation/xcode)
- [Information Property List](https://developer.apple.com/documentation/bundleresources/information-property-list)
- [Adding Capabilities](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app)

---

## xcodegen — project management

Instead of manually managing `.xcodeproj`, use [xcodegen](https://github.com/yonaskolb/XcodeGen).

### Installation
```bash
brew install xcodegen
```

### project.yml (minimal)
```yaml
name: MyApp
options:
  bundleIdPrefix: com.company
  deploymentTarget:
    iOS: "16.0"

targets:
  MyApp:
    type: application
    platform: iOS
    sources: [MyApp]
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.company.myapp
      SWIFT_VERSION: "5.9"
      TARGETED_DEVICE_FAMILY: "1"   # 1=iPhone, 2=iPad, 1,2=Universal
    info:
      path: MyApp/Info.plist
      properties:
        CFBundleDisplayName: "My App"
        UILaunchStoryboardName: LaunchScreen
    entitlements:
      path: MyApp/MyApp.entitlements
```

### Generating the project
```bash
cd ios/
xcodegen generate
```

> **Important:** every time you add a new `.swift` file you need to re-run `xcodegen generate`, otherwise the file won't be included in the project.

---

## Folder structure

```
MyApp/
├── App/
│   ├── MyAppApp.swift          # @main
│   └── ContentView.swift
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── Endpoints.swift
│   │   └── Models.swift
│   ├── DesignSystem/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Components/
│   └── Extensions/
├── Features/
│   ├── Auth/
│   ├── Listings/
│   ├── Profile/
│   └── Chat/
└── Resources/
    ├── Assets.xcassets
    └── en.lproj/
        └── Localizable.strings
```

---

## Info.plist — permissions

All `NSUsageDescription` entries are mandatory — without them the App Store will reject the app.

```xml
<!-- Geolocation -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show nearby listings.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We use your location to show nearby listings.</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Take photos for your listings.</string>

<!-- Photo library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose photos for your listings.</string>

<!-- Notifications — no description needed in Info.plist, only requestAuthorization() -->

<!-- Network (if you use HTTP locally) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Add via `info.properties` in `project.yml`:
```yaml
NSLocationWhenInUseUsageDescription: "We use your location to show nearby listings."
NSCameraUsageDescription: "Take photos for your listings."
NSPhotoLibraryUsageDescription: "Choose photos for your listings."
```

---

## Entitlements

`MyApp.entitlements` file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <!-- Push notifications -->
    <key>aps-environment</key>
    <string>development</string>   <!-- production for release builds -->

    <!-- Apple Sign In -->
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>

    <!-- Background geolocation (if needed) -->
    <key>com.apple.developer.location.always-and-when-in-use</key>
    <true/>
</dict>
</plist>
```

---

## Minimum iOS version

**iOS 16** is recommended as the minimum:
- SwiftUI NavigationStack (replaces the deprecated NavigationView) — iOS 16+
- `ContentUnavailableView` — iOS 17+ (implement fallback manually)
- `MapContentBuilder` (new Map API) — iOS 17+ (use the old `Map(coordinateRegion:)` for iOS 16)

---

## UI language — follows the phone's language setting

The app should automatically display the language set in the phone's settings. For this to work, localization must be configured correctly from the start.

### 1. Add languages to the project

In `project.yml`:
```yaml
options:
  developmentLanguage: en

settings:
  DEVELOPMENT_LANGUAGE: en

targets:
  MyApp:
    settings:
      SWIFT_VERSION: "5.9"
      # Add localizations
    info:
      properties:
        CFBundleLocalizations:
          - en
          - ru
          - uk
          # add the languages you need
```

Or in Xcode: **Project** → **Info** → **Localizations** → `+` → select a language.

### 2. Localization file structure

```
Resources/
├── en.lproj/
│   └── Localizable.strings
├── ru.lproj/
│   └── Localizable.strings
└── uk.lproj/
    └── Localizable.strings
```

### 3. Always write strings through localization — never hardcode

```swift
// WRONG
Text("Search listings...")
Button("Close") { }

// CORRECT
Text("search.placeholder")        // SwiftUI reads from Localizable.strings automatically
Button(String(localized: "action.close")) { }
```

`en.lproj/Localizable.strings`:
```
"search.placeholder" = "Search listings...";
"action.close" = "Close";
"action.save" = "Save";
```

`ru.lproj/Localizable.strings`:
```
"search.placeholder" = "Поиск объявлений...";
"action.close" = "Закрыть";
"action.save" = "Сохранить";
```

### 4. How it works

iOS picks the appropriate `.lproj` file based on the phone's language — no additional configuration is needed. If the phone language is `ru` → `ru.lproj/Localizable.strings` is used. If the language is not available → falls back to `en`.

### 5. Testing different languages

In Xcode Simulator: **Settings** → **General** → **Language & Region** → change the language.

Or launch the scheme with an argument:
```
Edit Scheme → Run → Arguments → Arguments Passed On Launch:
-AppleLanguages (ru)
```

### 6. Numbers, dates, currency — automatically formatted by locale

```swift
// Price — formatted according to the phone's locale
Text(price, format: .currency(code: "USD"))

// Date — locale-specific format
Text(date, style: .date)

// Number
Text(count, format: .number)
```

> Never format manually using `String(format: "$%.2f", price)` — this ignores the locale.

---

## Localization

Create `Localizable.strings` for each language:
```
Resources/
├── en.lproj/Localizable.strings
└── ru.lproj/Localizable.strings
```

Use in code:
```swift
Text(String(localized: "listing.title"))
// or
Text("listing.title")  // SwiftUI localizes automatically
```

In `project.yml`:
```yaml
settings:
  DEVELOPMENT_LANGUAGE: en
```
