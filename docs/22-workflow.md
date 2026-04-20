# Sprint Workflow

Every feature or fix follows this sequence. Each step feeds into the next.

```
Think → Plan → Build → Review → Test → Ship → Reflect
```

---

## The Sequence

### 1. Think — before writing code

Answer these before touching any file:
- What is the exact problem you're solving?
- Who experiences it and how often?
- What is the simplest version that solves it?
- What could go wrong?

If you can't answer these clearly, you're not ready to build yet.

### 2. Plan — architecture first

For any feature that touches more than 2 files:
- Write the data flow: input → processing → output
- Identify which layer handles what (see `docs/02-architecture.md`)
- Identify the failure modes: what if the network is down? what if the user is not authenticated?
- Decide on the test strategy before writing code

For large features: write a brief design doc in `docs/` before starting.

### 3. Build — with discipline

Rules while building:
- One logical change per commit (see `docs/23-git-workflow.md`)
- Follow the patterns already in the project — don't invent new ones
- Read the official docs for the exact library version you're using
- Never hardcode secrets — use `.env` files (see `docs/12-security.md`)
- Write tests alongside the code, not after

### 4. Review — `/review`

Before opening a PR, run `/review`. It will:
- Find bugs that pass CI but fail in production
- Auto-fix obvious issues (empty catches, dead code, missing `.env.example` entries)
- Flag architectural deviations
- Run a security pass

### 5. Test — `/qa`

Run `/qa [staging-url]` to test the actual running application:
- Test every changed user flow end-to-end
- Test edge cases (empty input, long input, rapid actions)
- Verify regressions didn't sneak in
- Every bug found gets a regression test before fixing

### 6. Ship — `/ship`

Run `/ship` to go from "done" to "in production":
- Syncs with main, runs tests
- Audits test coverage for new code
- Bisects commits if needed
- Opens a PR with a proper description
- Updates `CHANGELOG.md`

### 7. Reflect — after each sprint

Weekly or after each feature:
- What slowed you down?
- What broke unexpectedly?
- What pattern should be added to `docs/` to prevent recurrence?
- Update `docs/14-checklist.md` if new checklist items emerged

---

## Skill Commands

| Command | When to use |
|---------|-------------|
| `/review` | Before opening any PR |
| `/ship` | When the feature is done and reviewed |
| `/qa [url]` | After deploying to staging |
| `/security` | Before any production release, or when touching auth/payments |
| `/investigate [bug]` | When debugging — use instead of guess-and-patch |

---

## Parallel work

When running multiple features in parallel (separate branches):
- Each branch is its own mini-sprint: Plan → Build → Review → Test → Ship
- Don't merge unreviewed branches into each other
- Keep branches short-lived (ideally < 1 week)
- Use worktrees for true isolation: `git worktree add ../project-feature-x feature/x`
