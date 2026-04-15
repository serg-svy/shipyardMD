# 00b — Development Rules (required reading)

These rules are not recommendations. This is the minimum quality standard.
Violating any of them = reason for a review comment or MR rejection.

---

## 1. Before making changes — read the documentation for the version you're using

Not a Stack Overflow post from 2019. Not a random Medium article. The official docs for the version you are using.

```
Bad:  "I know how this works" → writing from memory
Bad:  found an example on SO → copied it → didn't check the version
Good: opened laravel.com/docs/11.x → found the right section → implemented it
```

**Why it matters:** APIs change between versions. What worked in Laravel 9 is deprecated in Laravel 11. What worked in Swift 5.7 works differently in Swift 5.9.

Links to documentation — in file [21-stacks.md](21-stacks.md).

---

## 2. Study how similar things are already implemented in the project

Before writing a new component, service, or screen — find a similar one in the codebase and follow the same pattern.

```
Bad:  invented your own way to make API requests, even though APIClient already exists
Bad:  created a new class for error handling, even though AppError exists
Good: found a similar screen → looked at how the ViewModel is structured there → repeated the structure
```

**How to search:**
```bash
# Find similar implementations in the project
grep -r "ListingsViewModel" --include="*.swift" .
grep -r "AllowedFilter" --include="*.php" .
```

**Why it matters:** codebase consistency. When everyone follows the same pattern — any developer can read any file without explanation.

---

## 3. Propose senior-level solutions

No hacks, quick fixes, or "if it works, don't touch it".

```
Bad:  try { } catch { }  // empty catch — swallowed the error
Bad:  // TODO: fix later  // and you never fix it
Bad:  force unwrap  →  viewModel.data!.first!.id
Bad:  hardcoding strings, URLs, keys directly in code
Bad:  copy-pasting 50 lines instead of extracting into a function

Good: handle errors explicitly via AppError
Good: extract repeated code into a method / component
Good: use constants / configs / environment variables
Good: if you don't know the right solution — ask / read the docs
```

**Self-check question:** "If a tech lead sees this code a year from now — will they understand what's happening here?"

---

## 4. Test the full flow locally before MR

Not "the component exists in the code". Not "it compiles for me". The full scenario from start to finish.

```
Bad:  added an endpoint → tested one request via Postman → created MR
Bad:  added a screen → checked that it opens → created MR
Bad:  fixed a migration → didn't run it locally → "we'll check on the server"

Good: added a feature → went through the entire user flow manually:
       registration → login → created a listing → it appeared
       → edited → deleted → confirmed the database is clean
```

**Checklist before each MR:**
- [ ] Ran the project locally (not just built it)
- [ ] Went through the main scenario manually in full
- [ ] Checked edge cases (empty data, network error, no permissions)
- [ ] Ran tests locally (`php artisan test` / `xcodebuild test`)
- [ ] No uncommitted `.env` files, keys, or tokens

Detailed checklist → [14-checklist.md](14-checklist.md)

---

## 5. Don't assume code works — verify it

Assumption = source of 80% of production bugs.

```
Bad:  "I think the filter works, we've done this before"
Bad:  "this function should return an array" (didn't verify)
Bad:  "the migration probably applied"
Bad:  "the push notification should arrive" (didn't test on a real device)

Good: curl / Postman → confirmed the API returned the correct data
Good: dd() / dump() / print() → saw the real value
Good: php artisan migrate:status → confirmed it applied
Good: set a breakpoint → stepped through the debugger
```

**Verification tools:**
```bash
# Laravel — real data in DB
php artisan tinker
>>> App\Models\Listing::where('user_id', 2)->count()

# Laravel — migration status
php artisan migrate:status

# iOS — real-time logs
# Xcode → Debug → Attach to Process

# Docker — what's actually happening in the container
docker compose logs -f app
docker exec myapp_app php artisan queue:work --once  # run a job manually
```

---

## Summary — questions before submitting code

Before clicking "Create MR" — answer each one:

```
1. Did I read the docs for the correct version of what I implemented?
2. Did I look at how similar things are done in the project and follow the same pattern?
3. Are there no hacks, force unwraps, empty catches, or hardcoded values?
4. Did I go through the full user flow manually and does everything work?
5. Did I check edge cases (no data, error, no permissions)?
6. Are tests running and green?
7. Does the commit contain no secrets, keys, or .env files?

If even one answer is "no" — the MR is not ready.
```
