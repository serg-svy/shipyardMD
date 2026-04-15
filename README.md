<div align="center">

# ShipyardMD 

**An AI-powered development framework for [Claude Code](https://claude.ai/code).**

Start any project — iOS app, web SaaS, e-commerce, Telegram bot, and more — 
with clean architecture, security-first defaults, and production-ready infrastructure.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-blueviolet)](https://claude.ai/code)
[![Stars](https://img.shields.io/github/stars/serg-svy/shipyardMD?style=social)](https://github.com/serg-svy/shipyardMD)

[Quick Install](#quick-install) · [How It Works](#how-it-works) · [Supported Stacks](#supported-stacks) · [Docs](docs/) · [Templates](templates/)

</div>

---

## What Is ShipyardMD?

ShipyardMD is a framework you clone once and open in Claude Code. Claude automatically reads the configuration, asks you 4 questions to understand your project, then guides you through the entire build — architecture, code, testing, security, and deployment.

No boilerplate hunting. No copy-pasting Stack Overflow. Senior-level decisions from the first line of code.

---

## Quick Install

**One command:**
```bash
curl -fsSL https://raw.githubusercontent.com/serg-svy/shipyardMD/main/install.sh | bash
```

**Or clone manually:**
```bash
git clone https://github.com/serg-svy/shipyardMD.git my-project
cd my-project
claude .
```

Claude opens and starts asking questions. That's the entire setup.

---

## How It Works

```
You clone ShipyardMD
 ↓
Open in Claude Code → Claude reads CLAUDE.md automatically
 ↓
Claude asks 4 questions:
 1. Your experience level (beginner / junior / mid / senior)
 2. What to build (iOS / web / SaaS / bot / etc.)
 3. Main constraint (no budget / solo / speed / scale)
 4. Design ready? (Figma link / screenshots / none)
 ↓
Claude recommends the right stack
 ↓
Requests your Figma file (if you have one)
 ↓
Presents a phased development plan
 ↓
Guides every step with senior-level standards:
 Clean Architecture enforced
 Secrets never in code
 Full flow tested before every PR
 Official docs referenced, not blog posts
```

---

## Supported Stacks

| Project Type | Stack |
|---|---|
| iOS App | SwiftUI + MVVM + Laravel API |
| iOS + Android | Flutter + Firebase |
| Cross-platform mobile | React Native + Expo |
| Web SaaS | Next.js 14 + Supabase + Vercel |
| Content website | WordPress + ACF Pro |
| E-commerce | Shopify / WooCommerce |
| Telegram Bot / Mini App | Python aiogram + FastAPI |
| High-traffic API | Go + PostgreSQL + Redis |
| Desktop App | Tauri / Electron |
| Enterprise web | Angular + NestJS |

Full matrix with documentation links → [docs/21-stacks.md](docs/21-stacks.md)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│ DEVFORGE │
│ │
│ CLAUDE.md ──────────► Claude reads on project open │
│ │ │
│ ▼ │
│ 4 Questions ──► Stack Selection ──► Dev Plan │
│ │ │
│ ┌──────────▼──────────┐ │
│ │ docs/ (22 md) │ │
│ │ Architecture │ │
│ │ Networking │ │
│ │ Security │ │
│ │ Docker + CI/CD │ │
│ │ Testing │ │
│ │ Deployment │ │
│ └──────────┬──────────┘ │
│ │ │
│ ┌──────────▼──────────┐ │
│ │ templates/ │ │
│ │ ios-laravel/ │ │
│ │ nextjs-supabase/ │ │
│ │ laravel-api/ │ │
│ │ flutter-firebase/ │ │
│ │ telegram-bot/ │ │
│ └─────────────────────┘ │
│ │
│ .claude/settings.json ──► Secret detection hooks │
│ .mcp.json ──► Figma MCP pre-configured │
│ .gitignore ──► Covers all sensitive files │
│ .env.example ──► Secrets template │
└─────────────────────────────────────────────────────────┘
```

---

## Security — Built In From Day One

Claude enforces these rules on every project:

- **Never writes secrets, tokens, or API keys** into committed files
- **Alerts immediately** if credentials are detected in code (pre-write hook)
- `.gitignore` covers all sensitive files out of the box — `.env`, keys, certificates, `vendor/`, `node_modules/`
- `.env.example` provides the full secrets template with **empty values only**
- Full security guide → [docs/12-security.md](docs/12-security.md)

---

## Development Standards Claude Enforces

Every project built with ShipyardMD follows these non-negotiable rules:

| Rule | Why |
|---|---|
| Read official docs for the exact version in use | API changes between versions — no assumptions |
| Follow existing patterns in the project | Consistency > personal preference |
| Senior-level solutions only | No force unwraps, no empty catch, no hardcoded values |
| Test the full user flow end-to-end locally | Not just "the file exists" |
| Verify, don't assume | Logs, debugger, or actual tests — pick one |

Full rules → [docs/00b-dev-rules.md](docs/00b-dev-rules.md)

---

## Infrastructure Approach

```
MVP → Hetzner VPS €4/mo + Docker Compose + Cloudflare (free CDN + DDoS)

Growth → Load Balancer + 2× app servers + PostgreSQL read replica + Redis cache

Enterprise → Kubernetes + AWS/GCP + ElastiCache + Elasticsearch

CI/CD Rule (saves money on server RAM):
 Build on CI Runner → push image to Registry
 Production server: docker pull + docker run only
 Result: downscale from t3.large ($66) to t3.small ($20)
```

Full infrastructure guide → [docs/21-stacks.md](docs/21-stacks.md)

---

## What's Inside

```
shipyardMD/
├── CLAUDE.md # Claude reads this automatically on open
├── README.md # This file
├── install.sh # One-command setup script
├── .gitignore # Covers macOS, iOS, PHP, Node, Python, Docker
├── .env.example # Secrets template — no real values
├── .mcp.json # Figma MCP pre-configured
│
├── .claude/
│ └── settings.json # Secret detection hook + CLI permissions
│
├── docs/
│ ├── 00-project-type.md # Project type questions & stack selection
│ ├── 00b-dev-rules.md # Development rules (mandatory)
│ ├── 01-project-setup.md # Xcode 26.4, xcodegen, localization
│ ├── 02-architecture.md # MVVM, Clean Architecture, navigation patterns
│ ├── 03-networking.md # APIClient protocol, auth tokens, DI
│ ├── 04-maps.md # MapKit, gesture interception fix
│ ├── 05-media.md # Image loading, card height pattern
│ ├── 06-auth.md # Keychain, login flow, token storage
│ ├── 07-push-notifications.md # APNs, FCM, Laravel push
│ ├── 08-app-store-publish.md # App Store submission full checklist
│ ├── 09-docker-backend.md # Docker Compose, RAM optimization, CI/CD
│ ├── 10-figma-mcp.md # Figma MCP design-to-code workflow
│ ├── 11-testing.md # XCTest, PHPUnit, mock patterns
│ ├── 12-security.md # Keychain, .gitignore, .env best practices
│ ├── 13-environments.md # Dev / staging / production configs
│ ├── 14-checklist.md # Pre-launch & daily checklists
│ ├── 15-clean-architecture.md # DI via protocols, AppError, OSLog, SwiftLint
│ ├── 16-realtime.md # WebSockets, Laravel Reverb, Soketi
│ ├── 17-offline-cache.md # CacheService with TTL, NetworkMonitor
│ ├── 18-deep-links.md # Universal Links, DeepLinkRouter
│ ├── 19-analytics.md # Firebase Analytics, event tracking
│ ├── 20-performance.md # N+1 queries, LazyVStack, Instruments
│ └── 21-stacks.md # Complete stack matrix — all platforms
│
└── templates/
 ├── ios-laravel/ # SwiftUI + Laravel: docker-compose, Dockerfile
 ├── nextjs-supabase/ # Next.js 14 + Supabase: package.json + config
 ├── laravel-api/ # Laravel REST API: GitLab CI + prod compose
 ├── flutter-firebase/ # Flutter + Firebase: pubspec + structure
 └── telegram-bot/ # aiogram + FastAPI: requirements + docker
```

---

## Requirements

- [Claude Code](https://claude.ai/code) — install via `npm i -g @anthropic-ai/claude-code`
- Git
- Docker + Docker Compose (for backend / full-stack projects)
- Xcode 26.4+ (for iOS projects, macOS only)

---

## Contributing

Contributions welcome. All documentation and code must be in **English**.

- Found a bug → open an issue
- Want to add a stack or template → open a PR with docs + template
- Improving existing docs → keep the same structure, update links

---

## License

MIT — free to use, fork, and build commercial products with.

---

<div align="center">

Built to help developers ship faster, cleaner, and safer. 
**Star it if it saves you time ⭐**

</div>
