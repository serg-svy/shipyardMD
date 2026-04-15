# 08 — App Store Publishing

## Documentation
- [App Store Connect](https://developer.apple.com/help/app-store-connect/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Certificates, IDs & Profiles](https://developer.apple.com/account/resources/)
- [TestFlight](https://developer.apple.com/testflight/)

---

## Apple Developer Account

1. Register at [developer.apple.com](https://developer.apple.com) — $99/year
2. Wait for confirmation (usually 1-2 days)
3. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/certificates/list)

---

## Bundle ID

1. **Identifiers** → `+` → App IDs → App
2. Bundle ID: `com.company.appname` (reverse domain)
3. Enable the required **Capabilities**: Push Notifications, Sign in with Apple, Maps, etc.

---

## Certificates

### Distribution Certificate
1. **Certificates** → `+` → Apple Distribution
2. Create a CSR via Keychain Access → Certificate Assistant → Request a Certificate
3. Upload the `.certSigningRequest`, download and install the `.cer`

### APNs Key (for push notifications)
1. **Keys** → `+` → Apple Push Notifications service (APNs)
2. Download the `.p8` file — **save it, it can only be downloaded once!**
3. Note the Key ID and Team ID

---

## Provisioning Profile

1. **Profiles** → `+` → App Store Connect
2. Select the Bundle ID and Distribution Certificate
3. Download and install the `.mobileprovision` by double-clicking it

In Xcode: **Project Settings** → **Signing & Capabilities** → disable "Automatically manage signing" and select the profile.

---

## App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → `+` → New App
3. Fill in:
   - Platform: iOS
   - Name: app name (can be changed later)
   - Primary language
   - Bundle ID (from Identifiers)
   - SKU: unique identifier (e.g. `myapp-ios-001`)

---

## Screenshots (required)

Screenshots are required for each device size:

| Device | Size |
|---|---|
| 6.9" (iPhone 16 Pro Max) | 1320×2868 px |
| 6.5" (iPhone 14 Plus) | 1284×2778 px |
| 5.5" (iPhone 8 Plus) | 1242×2208 px |
| 12.9" iPad Pro | 2048×2732 px |

> Minimum: 6.9" and 6.5" — the rest are inherited.

Capture via Xcode Simulator → `Cmd+S` for a screenshot.

---

## App Privacy (required)

In App Store Connect → **App Privacy**:
- Specify what data you collect: geolocation, phone number, photos, email
- For each data type — specify the purpose
- Indicate whether it is linked to the user's identity

---

## Privacy Policy (required)

Required if the app collects any user data.  
Minimal hosting options: GitHub Pages, Notion, Google Sites.

Add the URL in App Store Connect → **App Information** → Privacy Policy URL.

---

## Exporting from Xcode

1. `Product` → `Archive`
2. After archiving: `Distribute App` → `App Store Connect`
3. Choose `Upload` (automatically uploads to ASC)
4. After ~10 minutes the build will appear in TestFlight

---

## TestFlight (beta testing)

1. App Store Connect → **TestFlight** → select a build
2. **Internal Testing** — up to 100 users, no Apple review required
3. **External Testing** — up to 10,000 users, review required (usually 1-2 days)

Add testers by email or via a public link.

---

## Submission — checklist before submitting

- [ ] Icon 1024×1024 px in Assets.xcassets (no rounded corners — Apple will round them)
- [ ] Screenshots for all required device sizes
- [ ] Privacy Policy URL filled in
- [ ] App Privacy filled in
- [ ] App description (at least 100 characters)
- [ ] Keywords for search
- [ ] App category
- [ ] Age rating filled in
- [ ] Price specified (Free / paid)
- [ ] Support URL

---

## Common rejection reasons

| Reason | Solution |
|---|---|
| Crash during review | Test on a real device before submitting |
| No permission explanation | Add `NSUsageDescription` to Info.plist |
| Placeholder content | Remove all "lorem ipsum", "test data" |
| Login via social only | If Apple Sign In is offered — it is mandatory |
| No Privacy Policy | Create one and add the URL |
| App requires account without explanation | Add a demo mode or explain why an account is needed |

---

## Timelines

- **First review:** 24-48 hours
- **Subsequent updates:** 12-24 hours
- **Rejection → resubmit:** a new review cycle begins

> Tip: Submit on Monday or Tuesday — shorter queue, faster review.
