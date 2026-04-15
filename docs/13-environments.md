# 13 — Environments (dev / staging / production)

---

## Three environments

| | Dev | Staging | Production |
|---|---|---|---|
| Purpose | Development | Testing | Users |
| Database | Local Docker | Separate server | Production server |
| Data | Fake (seeders) | Copy of prod | Real |
| API URL | `http://192.168.1.x` | `https://staging.api.myapp.com` | `https://api.myapp.com` |
| Bundle ID | `com.company.myapp.dev` | `com.company.myapp.staging` | `com.company.myapp` |

---

## iOS — `.xcconfig` files

```
ios/
├── Configs/
│   ├── Dev.xcconfig          # do not commit if it contains secrets
│   ├── Staging.xcconfig
│   └── Production.xcconfig
```

`Dev.xcconfig`:
```
API_BASE_URL = http://192.168.1.100
BUNDLE_ID_SUFFIX = .dev
APP_NAME = MyApp Dev
```

`Production.xcconfig`:
```
API_BASE_URL = https://api.myapp.com
BUNDLE_ID_SUFFIX =
APP_NAME = MyApp
```

In `project.yml`:
```yaml
targets:
  MyApp:
    settings:
      configs:
        Debug:   Configs/Dev.xcconfig
        Release: Configs/Production.xcconfig
    info:
      properties:
        API_BASE_URL: $(API_BASE_URL)
        CFBundleDisplayName: $(APP_NAME)
        CFBundleIdentifier: com.company.myapp$(BUNDLE_ID_SUFFIX)
```

In code:
```swift
enum AppConfig {
    static let apiBaseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as! String
}
```

---

## Backend — .env for each environment

```
backend/
├── .env              # local dev — do NOT commit
├── .env.example      # template — commit this
├── .env.testing      # for PHPUnit — do NOT commit
└── .env.staging      # staging — do NOT commit (deploy separately)
```

### Key differences in production .env

```
APP_ENV=production
APP_DEBUG=false           # must be false — do not expose stack traces
APP_URL=https://api.myapp.com

LOG_LEVEL=error           # do not log everything

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# HTTPS only
FORCE_HTTPS=true
```

---

## Seeder — dev only

```php
// DatabaseSeeder.php
public function run(): void
{
    // Base data — always run
    $this->call(CategorySeeder::class);

    // Test data — only in non-production environments
    if (app()->isLocal() || app()->environment('staging')) {
        $this->call([
            UserSeeder::class,
            ListingSeeder::class,
        ]);
    }
}
```

```bash
# Dev
docker exec myapp_app php artisan db:seed

# Production — categories and reference data only
docker exec myapp_app php artisan db:seed --class=CategorySeeder
```
