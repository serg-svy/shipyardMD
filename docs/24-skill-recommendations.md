# Skill Recommendations

ShipyardMD automatically suggests the right slash command at the right moment during development. You don't need to remember when to use each skill — Claude will tell you.

---

## Available Skills

| Command | Role | When to use |
|---------|------|-------------|
| `/review` | Staff Engineer | Before every PR — code review, security pass, auto-fix |
| `/ship` | Release Engineer | When feature is done — sync, test, PR, CHANGELOG |
| `/qa [url]` | QA Lead | After staging deploy — real user flow testing |
| `/security` | Security Officer | Before production release, auth/payments changes |
| `/investigate [bug]` | Debugger | When something is broken — systematic root cause analysis |

---

## When Claude suggests each skill

### `/review`
Triggered when you say: *"done", "finished", "ready", "let's push", "create PR", "merge this"*

What it does:
- Reads every changed file in full
- Auto-fixes: empty catch blocks, force unwraps, dead code, missing `.env.example` entries
- Flags: architectural deviations, missing tests, functions over 60 lines
- Security pass: secrets scan, SQL injection, missing auth checks

### `/investigate`
Triggered when you say: *"I found a bug", "something is broken", "it's not working", "why is this failing"*

Protocol:
1. Reproduce the bug first — never fix what you can't reproduce
2. Form max 3 hypotheses, test in order
3. Confirm root cause before writing any fix
4. Fix only the confirmed cause
5. Write a regression test
6. Verify the original flow works

Rule: **no fix without investigation**. No guessing, no patching.

### `/qa [url]`
Triggered when you say: *"I deployed to staging", "can you test this", "check if it works"*

What it does:
- Tests every changed user flow end-to-end
- Tests edge cases: empty input, long input, special characters, rapid actions
- Runs regression check on core flows
- Every bug found → fixed → regression test written → re-verified

### `/security`
Triggered before: *production release, auth changes, payment integration, user data handling*

Covers:
- OWASP Top 10 (A01–A10)
- STRIDE threat model per component
- Secrets scan across all committed files
- Only reports findings with 8/10+ confidence — no false positives

### `/ship`
Triggered when you say: *"ship it", "release", "deploy to prod", "let's merge"*

Steps:
1. Pre-flight: secrets scan, `.env.example` check
2. Sync with main
3. Run tests (reads test command from CLAUDE.md)
4. Coverage audit for new code
5. Bisect commits if needed (one logical change per commit)
6. Push + open PR with structured description
7. Update CHANGELOG.md

---

## Recommendation style by experience level

### Beginners (answered A or B to the experience question)

Claude explains the why and reminds after every milestone:
- After first working feature → suggests `/review`
- After any bug → suggests `/investigate`
- Before showing to users → suggests `/review` + `/security`

### Experienced developers (answered C or D)

Claude is brief — peer-level suggestions, no explanation unless asked:
- "Want me to run `/review`? I'll auto-fix the obvious stuff."
- "Run `/investigate` — saves time vs. guessing."
- "Worth a `/security` pass before this lands."

---

## How skills are installed

`install.sh` automatically creates symlinks from `skills/` into `.claude/skills/`:

```
.claude/skills/
├── review/SKILL.md   → skills/review/SKILL.md
├── ship/SKILL.md     → skills/ship/SKILL.md
├── qa/SKILL.md       → skills/qa/SKILL.md
├── security/SKILL.md → skills/security/SKILL.md
└── investigate/SKILL.md → skills/investigate/SKILL.md
```

Claude Code discovers them automatically — no additional setup needed.

To reinstall skills manually:
```bash
./install.sh
```

---

## Adding a new skill

1. Create `skills/<name>/SKILL.md`
2. Add a trigger rule to the `PROACTIVE SKILL SUGGESTIONS` section in `CLAUDE.md`
3. Add a row to the table in this file
4. `install.sh` will pick it up automatically on next run
