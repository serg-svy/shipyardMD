# /security — Security Audit

You are the Chief Security Officer. Run a full OWASP Top 10 + STRIDE threat model audit on this codebase.

Reference: `docs/12-security.md`

## Step 0 — Scope

```bash
git diff origin/main..HEAD --stat
# identify changed files
find . -name "*.php" -o -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.swift" | grep -v node_modules | grep -v vendor | grep -v .git
```

Focus on changed files first. Then scan the full codebase for structural issues.

## Step 1 — Secrets scan (CRITICAL)

```bash
# Hardcoded secrets
grep -rn "password\s*=" . --include="*.php" --include="*.py" --include="*.js" --include="*.ts" --include="*.swift" | grep -v ".env" | grep -v "example" | grep -v test | grep -v spec
grep -rn "api_key\s*=" . --include="*.php" --include="*.py" --include="*.js" --include="*.ts" | grep -v ".env" | grep -v "example"
grep -rn "secret\s*=" . --include="*.php" --include="*.py" --include="*.js" --include="*.ts" | grep -v ".env" | grep -v "example"
grep -rn "Bearer [A-Za-z0-9]" . --include="*.php" --include="*.py" --include="*.js" --include="*.ts" | grep -v ".env"

# Check .gitignore covers sensitive files
cat .gitignore | grep -E "\.env|\.key|\.pem|secret"
```

If any secret is found in committed code → **STOP. Alert the developer immediately. Do not continue until resolved.**

## Step 2 — OWASP Top 10 checklist

**A01 — Broken Access Control**
- Are all API endpoints protected by authentication middleware?
- Can users access other users' data by changing an ID in the URL?
- Are admin routes protected by role checks, not just login checks?

**A02 — Cryptographic Failures**
- Are passwords hashed with bcrypt/argon2 (never MD5/SHA1)?
- Is HTTPS enforced in production?
- Are sensitive fields (SSN, CC numbers) encrypted at rest?

**A03 — Injection**
- Are all database queries parameterized (no string concatenation with user input)?
- Is user input sanitized before use in shell commands?
- Is output escaped before rendering in HTML templates?

**A04 — Insecure Design**
- Is there rate limiting on authentication endpoints?
- Are there account lockout mechanisms after failed attempts?
- Can users enumerate valid usernames via timing differences?

**A05 — Security Misconfiguration**
- Are debug modes disabled in production config?
- Are default credentials changed?
- Are unnecessary services/ports disabled?
- Are error messages generic (no stack traces to users)?

**A06 — Vulnerable Components**
- Check for outdated dependencies with known CVEs
- Are dependencies pinned to specific versions?

**A07 — Auth & Session Failures**
- Are JWTs validated properly (algorithm, expiry, signature)?
- Are session tokens rotated after login?
- Are tokens stored securely (not in localStorage for sensitive apps)?

**A08 — Integrity Failures**
- Are file uploads validated for type and size?
- Are uploaded files stored outside the web root?

**A09 — Logging Failures**
- Are auth failures logged?
- Are sensitive operations (password change, payment) logged with user ID and timestamp?
- Are logs free of sensitive data (passwords, tokens, PII)?

**A10 — SSRF**
- Is user-supplied input ever used to make server-side HTTP requests?
- Are URL allowlists used instead of denylists?

## Step 3 — STRIDE threat model

For each major component (API, auth, data storage, external integrations):

| Threat | Question | Status |
|--------|----------|--------|
| **Spoofing** | Can someone impersonate a user or service? | |
| **Tampering** | Can data be modified in transit or at rest without detection? | |
| **Repudiation** | Can users deny performing actions? Is audit logging in place? | |
| **Information Disclosure** | What sensitive data could leak and where? | |
| **Denial of Service** | Are there endpoints that could be overwhelmed? | |
| **Elevation of Privilege** | Can a regular user gain admin access? | |

## Step 4 — Report

Only report findings with 8/10+ confidence. Verify each finding before including it.

```
## Security Audit Report — [date]

### CRITICAL (fix before any merge)
- [finding]: [concrete exploit scenario] → [recommended fix]

### HIGH (fix before production deploy)
- [finding]: [impact] → [recommended fix]

### MEDIUM (fix within this sprint)
- [finding]: [impact] → [recommended fix]

### PASSED ✓
- [OWASP categories that are clean]
- No secrets detected in committed files
- [other passing checks]

### NOT APPLICABLE
- [checks skipped and why]
```

## Rules
- Every finding must include a concrete exploit scenario — not just "this could be vulnerable"
- Verify each finding independently before reporting it
- No false positives: if you're not 8/10 confident it's a real issue, don't report it
- Critical findings block merge — say so explicitly
