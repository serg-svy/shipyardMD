# 12 — Security

## Documentation
- [Keychain Services](https://developer.apple.com/documentation/security/keychain-services)
- [App Transport Security](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)

---

## .gitignore — always required

Create it at the project root BEFORE the first commit.

### `/ios/.gitignore`

```gitignore
# Xcode
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
build/
*.ipa
*.dSYM.zip
*.dSYM

# CocoaPods (if used)
Pods/
Podfile.lock

# SPM
.build/
*.resolved   # DO NOT ignore if you want reproducible builds — your choice

# Secrets
GoogleService-Info.plist    # Firebase config — never commit
Secrets.swift               # if you store keys in a file
*.p8                        # APNs keys
*.p12
*.mobileprovision

# System
.DS_Store
```

### `/backend/.gitignore`

```gitignore
# Laravel
.env
.env.*
!.env.example           # commit this one — template without secrets

storage/app/public/*    # uploaded files
storage/logs/*
bootstrap/cache/*
vendor/                 # dependencies — do not commit

# Keys
*.p8
*.pem
*.key
AuthKey_*.p8

# Docker volume data
docker/data/

# System
.DS_Store
Thumbs.db
```

### `/.gitignore` (monorepo root)

```gitignore
.DS_Store
*.env
*.env.*
!*.env.example
.env.local

# IDE
.idea/
.vscode/settings.json
*.swp
```

---

## .env — rules

### Never commit .env

```bash
# Check that .env is in gitignore
git check-ignore -v backend/.env
# should return: backend/.gitignore:1:.env  backend/.env
```

### Always keep .env.example up to date

```bash
# .env.example — template without values
APP_NAME=MyApp
APP_ENV=local
APP_KEY=                          # empty
APP_URL=http://localhost

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

REDIS_HOST=redis

MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_KEY=                  # empty

TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM=

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_BUCKET=
AWS_ENDPOINT=

APPLE_CLIENT_ID=
GOOGLE_CLIENT_ID=

APN_KEY_ID=
APN_TEAM_ID=
APN_APP_BUNDLE_ID=
```

### How to share secrets with the team

- Use **1Password**, **Bitwarden**, or **Doppler** to store secrets
- Never send `.env` via Slack/Telegram/email
- For CI/CD: use **GitHub Secrets** or **GitLab Variables**

---

## iOS — Keychain instead of UserDefaults

**UserDefaults is not encrypted** — the token is stored in plain text on the file system.
**Keychain is encrypted** — protected even if the device is not locked.

```swift
import Security

final class KeychainService {
    static let shared = KeychainService()
    private let tokenKey = "auth_token"

    func saveToken(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)   // delete the old one
        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// Usage
KeychainService.shared.saveToken(response.token)
KeychainService.shared.getToken()
KeychainService.shared.deleteToken()  // on logout
```

---

## iOS — no secrets in code

```swift
// WRONG — key is visible in the binary via strings
let apiKey = "sk-prod-xxxxxxxxxxxx"

// CORRECT — via a config file that is not committed
// In Info.plist:
// <key>API_BASE_URL</key>
// <string>$(API_BASE_URL)</string>  ← taken from .xcconfig

// In code:
let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
```

`.xcconfig` file (do not commit):
```
API_BASE_URL = https://api.myapp.com
```

---

## Backend — Laravel security

### Rate Limiting

```php
// routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    Route::get('/listings', [ListingController::class, 'index']);
});

// Strict limit for OTP — brute-force protection
Route::middleware(['throttle:5,1'])->group(function () {
    Route::post('/auth/send-otp', [AuthController::class, 'sendOtp']);
});
```

### Always validate on the backend

Even if iOS validates — the backend must validate too. iOS can be bypassed.

```php
$request->validate([
    'title'       => ['required', 'string', 'max:200'],
    'price'       => ['required', 'numeric', 'min:0', 'max:9999999'],
    'condition'   => ['required', 'in:new,like_new,good,fair'],
    'category_id' => ['required', 'exists:categories,id'],
    'photos.*'    => ['image', 'max:10240'],  // max 10MB per photo
]);
```

### Policy — action authorization

```php
// Only the owner can edit
class ListingPolicy
{
    public function update(User $user, Listing $listing): bool
    {
        return $user->id === $listing->user_id;
    }

    public function delete(User $user, Listing $listing): bool
    {
        return $user->id === $listing->user_id;
    }
}

// Register in AppServiceProvider
Gate::policy(Listing::class, ListingPolicy::class);

// In the controller
$this->authorize('update', $listing);  // 403 if not the owner
```

### APP_KEY — always generate it

```bash
# On first deployment
docker exec myapp_app php artisan key:generate

# Never use the same APP_KEY in dev and prod
```

---

## Security checklist before release

- [ ] Token stored in Keychain, not UserDefaults
- [ ] `.env` in `.gitignore`, not in the repository
- [ ] `.env.example` is up to date (all keys present, values empty)
- [ ] `GoogleService-Info.plist` in `.gitignore`
- [ ] APNs `.p8` key in `.gitignore`
- [ ] No hardcoded API keys in Swift code
- [ ] Rate limiting on OTP endpoint
- [ ] Policies configured for all protected endpoints
- [ ] `APP_DEBUG=false` in production `.env`
- [ ] `APP_ENV=production` in production
- [ ] HTTPS in production (not HTTP)
- [ ] All fields validated on the backend
