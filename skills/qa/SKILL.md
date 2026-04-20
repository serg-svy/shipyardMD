# /qa — Quality Assurance

You are a QA lead. Test the actual running application, find bugs, fix them, verify the fix.

**Usage:** `/qa https://staging.myapp.com` or `/qa` (will ask for the URL)

## Step 0 — Understand what changed

```bash
git log origin/main..HEAD --oneline
git diff origin/main..HEAD --stat
```

Read the diff. Understand what features or fixes are on this branch. This determines where to focus testing.

## Step 1 — Test the happy path for every changed feature

For each feature in the diff, test the complete user flow end-to-end:
1. Navigate to the relevant screen/page/endpoint
2. Perform the action as a real user would
3. Verify the expected result
4. Check for console errors or unexpected network requests

## Step 2 — Test edge cases

For every input field or user action tested in Step 1, also test:
- Empty input
- Very long input (500+ characters)
- Special characters (`<>'"&%`)
- Rapid repeated actions (double-tap, double-submit)
- Network slow / offline (if applicable)

## Step 3 — Regression check

Test core flows that existed before this branch to verify nothing broke:
- Authentication (login, logout, session persistence)
- Main navigation
- Data save/load cycle
- Any flow mentioned in `docs/14-checklist.md`

## Step 4 — Bug reporting and fixing

For each bug found:

1. **Document it:**
   ```
   Bug: [short description]
   Steps to reproduce: [numbered steps]
   Expected: [what should happen]
   Actual: [what happens]
   Severity: blocker / major / minor
   ```

2. **Fix it** with an atomic commit:
   ```bash
   git add [specific files]
   git commit -m "fix: [what was wrong and why]"
   ```

3. **Write a regression test** — a test that would have caught this bug. No fix without a test.

4. **Re-verify** — reproduce the original steps, confirm the bug is gone.

## Step 5 — QA Report

```
## QA Report — [date]
Branch: [branch name]
Tested URL: [URL]

### Bugs Fixed
- [bug description] → fixed in commit [hash], regression test added

### Bugs Found (needs fix before merge)
- [bug description] — severity: blocker/major/minor

### Passed ✓
- [flows that were tested and passed]

### Not Tested
- [anything out of scope or blocked]
```

## Rules
- Never declare "done" without running the actual user flow
- Every bug fix gets a regression test — no exceptions
- Blockers must be fixed before this skill completes
- If you can't reproduce a bug consistently, document what you tried
