# Git Workflow

---

## Commit Style

### The Rule: One Logical Change Per Commit

Every commit must be independently understandable and revertable.
`git bisect` must be able to pinpoint any bug to a single commit.

**Good bisection — split these into separate commits:**
- Rename/move files → separate from behavior changes
- Tests → separate from the implementation they test
- Config/env changes → separate from feature code
- Mechanical refactors (rename variable) → separate from new features
- Bug fixes → separate from unrelated improvements

**Format:**
```
type: short description (≤72 chars, imperative mood)

Optional body: explain WHY, not what. The diff shows what.
```

**Types:**
| Type | When |
|------|------|
| `feat:` | New feature for the user |
| `fix:` | Bug fix |
| `refactor:` | Code change with no behavior change |
| `test:` | Adding or fixing tests |
| `docs:` | Documentation only |
| `chore:` | Build, CI, deps — not user-facing |
| `security:` | Security fix |

**Examples:**
```bash
feat: add push notification opt-in screen
fix: prevent double-submit on payment form
refactor: extract APIClient from LoginViewModel
test: add regression test for empty cart checkout
security: parameterize user ID in profile query
```

---

## Branch Naming

```
feature/short-description
fix/what-is-broken
refactor/what-is-changing
```

Keep branches short-lived. Merge within a week if possible.

---

## Pull Request Format

**Title:** What the user can now do (or what was broken and is now fixed). Imperative, ≤70 chars.

**Body:**
```markdown
## What this does
- [bullet: user-facing change]
- [bullet: user-facing change]

## How to test
1. Go to [screen/URL]
2. Do [action]
3. Verify [expected result]

## Checklist
- [ ] Tests pass locally
- [ ] No secrets in committed files
- [ ] .env.example updated if new secrets added
- [ ] Full user flow tested end-to-end
- [ ] CHANGELOG.md updated
```

---

## CHANGELOG.md

### Format

```markdown
## [X.Y.Z] — YYYY-MM-DD

[2-4 sentences: what shipped. Write for users, not developers.
"You can now..." not "Refactored the..."]

### Added
- Feature name — short description of what the user gains

### Fixed
- What was broken — what the user experienced before vs after

### Changed
- What changed in existing behavior — migration notes if needed
```

### Rules

- **Write for users.** "You can now export your data as CSV" not "Added CSV export endpoint"
- **Real numbers when available.** "Reduces load time from 3s to 400ms" not "improved performance"
- **Never mention internal details:** refactors, test infrastructure, TODO tracking, dependency bumps (unless they fix a user-facing bug)
- **Every entry must make someone think:** "oh, I want to try that" or "glad that's fixed"
- **One entry per version.** Don't edit a version that's already on main.

### Version numbering

```
MAJOR.MINOR.PATCH

PATCH: bug fix, security fix, small improvement
MINOR: new feature, user-facing change
MAJOR: breaking change, major new capability
```

---

## Dangerous Operations — Always Confirm First

Never run these without explicit developer approval:

- `git push --force` or `git push --force-with-lease`
- `git reset --hard`
- `git rebase` on a shared branch
- `git branch -D` (delete branch)
- Anything with `--no-verify`

If CI fails after push: **fix the CI, don't merge around it.**
