# /ship — Release Workflow

You are the release engineer. Get this branch from "done" to "merged and deployed" safely.

## Step 0 — Pre-flight checklist

Run this and report status of each item:

```bash
# Check branch status
git status
git log origin/main..HEAD --oneline

# Check for secrets
grep -rn "password\s*=\s*['\"][^'\"]" . --include="*.py" --include="*.php" --include="*.js" --include="*.ts" 2>/dev/null | grep -v ".env" | grep -v "example"
grep -rn "api_key\s*=\s*['\"][^'\"]" . --include="*.py" --include="*.php" --include="*.js" --include="*.ts" 2>/dev/null | grep -v ".env" | grep -v "example"

# Check .env.example is up to date
cat .env.example 2>/dev/null || echo "No .env.example found"
```

Read `CLAUDE.md` for project-specific test and deploy commands. If missing, ask the developer.

## Step 1 — Sync with main

```bash
git fetch origin
git merge origin/main
```

Resolve conflicts if any. Never force-push to main.

## Step 2 — Run tests

Read CLAUDE.md for the test command. Common defaults:
- Laravel: `php artisan test`
- Next.js: `npm test` or `bun test`
- iOS: `xcodebuild test -scheme <scheme>`
- Flutter: `flutter test`
- Python: `pytest`

If tests fail: fix them before continuing. Do not proceed with failing tests.

## Step 3 — Coverage audit

Check if new code has tests. For every new function or endpoint added:
- Does a test exist for the happy path?
- Does a test exist for the main error case?

If critical paths lack tests, add them before shipping.

## Step 4 — Bisect commits

Every commit must be a single logical change. Check:

```bash
git log origin/main..HEAD --oneline
```

If multiple unrelated changes are in one commit, split them:
```bash
git reset HEAD~1  # unstage last commit
# re-stage and commit in logical groups
```

Good bisection examples:
- Rename/move → separate from behavior changes
- Tests → separate from implementation
- Config/env changes → separate from feature code

## Step 5 — Push and open PR

```bash
git push origin HEAD
```

Then open a PR with this structure:

**Title:** Short, imperative, ≤70 chars. What it does, not what you changed.

**Body:**
```
## What this does
[1-3 bullets: what the user can now do]

## How to test
[step-by-step QA instructions for the reviewer]

## Checklist
- [ ] Tests pass
- [ ] No secrets in committed files
- [ ] .env.example updated if new secrets added
- [ ] Full user flow tested locally
```

## Step 6 — Update CHANGELOG.md

Add an entry at the top. Format:

```markdown
## [X.Y.Z] — YYYY-MM-DD

[2-3 sentences: what shipped, what changed for the user. Specific and concrete.]

### Added
- ...

### Fixed
- ...

### Changed
- ...
```

Rules for CHANGELOG:
- Write for users, not developers
- "You can now..." not "Refactored the..."
- Real numbers when available ("reduces load time from 3s to 400ms")
- Never mention internal refactors, test infrastructure, or TODO tracking

## Rules
- Never skip failing tests
- Never `--no-verify` hooks unless developer explicitly asks
- Never force-push to main or master
- If CI fails after push: fix it, don't merge around it
