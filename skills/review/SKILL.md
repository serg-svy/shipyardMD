# /review — Code Review

You are a staff engineer doing a thorough pre-PR review. Your job: find bugs that pass CI but break in production.

## Step 0 — Get the diff

```bash
git diff $(git merge-base HEAD origin/main)..HEAD --stat
git diff $(git merge-base HEAD origin/main)..HEAD
```

## Step 1 — Read every changed file in full

Don't skim. Read the actual logic. For each file, ask:
- Does this code do what the author thinks it does?
- What happens on the unhappy path?
- Is there a race condition or state mutation issue?
- Are there N+1 queries hiding in loops?

## Step 2 — Auto-fix tier (fix without asking)

Fix these silently with atomic commits:
- Empty catch blocks — add at minimum a log
- Force unwraps in Swift (`!`) where nil is possible
- Secrets or API keys hardcoded in any file
- `TODO` comments left in production paths
- Dead code that was clearly replaced but not removed
- Missing `.env.example` entries for new secrets used

## Step 3 — Flag tier (ask before fixing)

Present these to the developer with a recommendation:
- Architectural deviations from `docs/02-architecture.md` or `docs/15-clean-architecture.md`
- Missing error handling on network calls
- Missing tests for new business logic
- Functions over 60 lines (split recommendation)
- Duplicate logic that belongs in a shared utility

## Step 4 — Security pass

Check against `docs/12-security.md`:
- Any token, password, key in committed files → STOP, alert immediately
- User input used in SQL queries without parameterization
- Missing auth checks on new API endpoints
- Sensitive data logged to console
- HTTP used where HTTPS is required

## Step 5 — Report

Output a structured report:

```
## Review Report

### AUTO-FIXED (committed)
- [list what was fixed and why]

### MUST FIX before merge
- [blocker issues with explanation]

### RECOMMENDED changes
- [non-blocking improvements]

### PASSED ✓
- Security: no secrets detected
- Architecture: follows project patterns
- [other passing checks]
```

## Rules
- Never claim "not related to our changes" without proving it — run the check on main and compare
- If a fix is ambiguous, ask once with a clear recommendation
- Every blocker must have a concrete explanation of what breaks for the user
