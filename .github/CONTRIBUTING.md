# Contributing to ShipyardMD

Thank you for contributing. ShipyardMD is built from real production experience — every addition should meet the same standard.

---

## Rules for All Contributions

1. **English only** — all documentation, comments, and code
2. **No hacks** — every recommendation must be a production-grade solution
3. **Link to official docs** — every technology must include a link to its official documentation
4. **Test your templates** — templates must run locally before submitting

---

## Adding a New Stack Doc

1. Create `docs/NN-stack-name.md` following the structure of existing docs
2. Include:
   - Language / framework / versions
   - Architecture recommendation
   - Key dependencies with official docs links
   - When to use / when not to use
   - At least one code example
3. Add the file to the docs table in `README.md` and `CLAUDE.md`

---

## Adding a New Template

1. Create `templates/your-stack/` with the minimum working skeleton:
   - `docker-compose.yml` (if backend involved)
   - `Dockerfile` (multi-stage where applicable)
   - `.dockerignore`
   - Main config file (`package.json`, `pubspec.yaml`, `requirements.txt`, etc.)
2. Test that `docker compose up` runs without errors

---

## Pull Request Checklist

- [ ] All text is in English
- [ ] Official documentation links are included for each technology
- [ ] No hardcoded secrets or credentials anywhere
- [ ] Template runs locally if included
- [ ] README.md and CLAUDE.md updated if new doc/template added
