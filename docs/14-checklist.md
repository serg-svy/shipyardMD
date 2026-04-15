# 14 — Checklist: Project Start and Pre-Release

---

## When Starting a New Project

### Day 1 — Before Writing Any Code

- [ ] Create `.gitignore` in the root, `/ios`, and `/backend` — **before the first commit**
- [ ] Create `backend/.env` from `.env.example`, fill in the secrets
- [ ] Make sure `.env` did not appear in `git status`
- [ ] Create `ios/Configs/Dev.xcconfig` (don't commit if it contains secrets)
- [ ] Generate `APP_KEY`: `php artisan key:generate`
- [ ] Activate PostGIS if geolocation is needed: `CREATE EXTENSION IF NOT EXISTS postgis;`
- [ ] Create a Bundle ID at [developer.apple.com](https://developer.apple.com/account/resources/)
- [ ] Enable the required Capabilities (Push, Sign in with Apple, Maps)

### Project Structure

- [ ] Run `xcodegen generate` after creating `project.yml`
- [ ] Folders: `Features/`, `Core/Network/`, `Core/DesignSystem/`, `Resources/`
- [ ] `Localizable.strings` created for each language
- [ ] `Colors.swift`, `Typography.swift`, `Spacing.swift` created from Figma tokens
- [ ] `APIClient.swift` with a protocol (so it can be mocked in tests)

### Tests — Set Up Right Away

- [ ] Add `MyAppTests` and `MyAppUITests` targets to `project.yml`
- [ ] Create `backend/tests/Feature/` and `backend/tests/Unit/` folders
- [ ] Create `backend/.env.testing` with a test database
- [ ] Verify that `php artisan test` runs without errors (even if the tests are empty)
- [ ] Verify that `Cmd+U` in Xcode passes

---

## Before Every Commit

- [ ] `php artisan test` — all tests green
- [ ] `Cmd+U` in Xcode — unit tests green
- [ ] `git status` — no `.env`, no `*.p8`, no `GoogleService-Info.plist`
- [ ] No hardcoded strings in the UI — only via `Localizable.strings`
- [ ] No `print()` or `dump()` calls that will reach production (use `logger()` with a condition)

---

## Before Releasing to the App Store

### Code

- [ ] Token is stored in Keychain, not in UserDefaults
- [ ] `APP_DEBUG=false` on the production server
- [ ] All `TODO:` comments addressed or documented
- [ ] No test data (test@test.com, "lorem ipsum", hardcoded user id)
- [ ] All API endpoints are protected by authorization where required
- [ ] Rate limiting on sensitive endpoints (OTP, login)
- [ ] Logs do not write personal data (phone number, email, tokens)

### iOS

- [ ] 1024×1024 icon without rounded corners added to Assets
- [ ] Launch Screen configured
- [ ] All `NSUsageDescription` entries filled in Info.plist (Location, Camera, Photos)
- [ ] `aps-environment` = `production` in entitlements
- [ ] Release scheme builds without warnings
- [ ] Tested on a real device (not only the simulator)
- [ ] All permissions verified on a clean device (first launch)
- [ ] Deep links work
- [ ] App works without internet (graceful degradation)

### App Store Connect

- [ ] Screenshots for 6.9" and 6.5" uploaded
- [ ] Description filled in (no "test", "demo", or placeholder text)
- [ ] Keywords filled in
- [ ] Privacy Policy URL is working
- [ ] App Privacy (data) section filled in
- [ ] Age rating set
- [ ] Category selected
- [ ] Price set

### Backend

- [ ] All migrations run on production
- [ ] Database backup configured
- [ ] `php artisan optimize` run
- [ ] `php artisan config:cache` run
- [ ] Queue worker is running (supervisor or Docker)
- [ ] SSL certificate is active and not expiring soon

---

## Quick Security Check

```bash
# Make sure .env is not in git
git ls-files | grep "\.env$"          # should be empty

# Search for hardcoded secrets in the code
grep -r "sk-" --include="*.swift" .   # OpenAI-style API keys
grep -r "password" --include="*.swift" . | grep -v "//\|Password\|field\|placeholder"
grep -r "192\.168\." --include="*.swift" .   # hardcoded IPs

# Laravel — check the config
docker exec myapp_app php artisan config:show app | grep debug
# should be: debug ... false  (in production)
```
