# How ShipyardMD Was Built — A Complete Record

This document is a full account of how this framework came to exist.
Every decision, every problem, every method, every conclusion.
Written so future contributors understand not just what is here, but why.

---

## Where It Started

ShipyardMD did not begin as a framework. It began as a single real iOS project — DealHub, a marketplace app with listings, maps, seller profiles, and chat.

During that development, patterns kept repeating:
- The same architecture decisions came up every project
- The same Docker RAM problems appeared on every server
- The same security mistakes (secrets in code) happened with new developers
- The same gesture interception bug in MKMapView confused everyone
- The same card image sizing issues in SwiftUI burned hours each time

The original knowledge lived in a folder called `ios-dev-guide` — 21 markdown files written in Russian, for personal use only. After several sessions of solving the same problems and documenting the solutions, the question came up: why keep this private?

---

## Phase 1 — Building the Knowledge Base

### What was documented first

The first files captured hard-won iOS + Laravel solutions that are not obvious from official docs:

**MKMapView gesture interception**
UIKit components eat all SwiftUI gestures before SwiftUI can process them.
The fix is not `.disabled(true)` and not `.allowsHitTesting(false)` on the map.
The fix is a `Color.clear.contentShape(Rectangle()).onTapGesture` overlay on top.
This is underdocumented. It burned hours. It went into `04-maps.md`.

**SwiftUI card image sizing**
Using `AsyncImage` directly inside a card gives different card heights depending on image aspect ratio. The fix: use a `Color` container with fixed height, then `.overlay { AsyncImage }` with `.clipped()`. The Color guarantees the height. The overlay fills it. The clip prevents overflow. This went into `05-media.md`.

**Multiple `.sheet()` conflicts**
Using three separate `@State var showX: Bool` properties for three sheets causes conflicts — SwiftUI only reliably presents one sheet at a time per view. The fix: one `enum Sheet: Identifiable` with all cases, one `@State var activeSheet: Sheet?`, one `.sheet(item: $activeSheet)` at the root. This went into `02-architecture.md`.

**Docker build on production server**
Building Docker images directly on the production server spikes RAM during the build. The actual observation from a tech lead: moving builds to a CI Runner allowed downscaling `srv-back` from `t3.large` (8GB, $66/mo) to `t3.small` (2GB, $20/mo). The server now only does `docker pull` + `docker run`. This went into `09-docker-backend.md`.

**PostGIS coordinate format**
`ST_SetSRID(ST_MakePoint(lng, lat), 4326)` works.
`::geography` cast does not work the same way and causes silent errors.
One line. Hours lost before finding it. Documented.

**Meilisearch requires MEILI_MASTER_KEY locally**
Even in development mode, without the key all API calls return 401.
This is buried in the docs. Now it is the first warning in the search section.

### Architecture decisions that became standards

Every file followed the same reasoning: what is the correct senior-level solution, not the quick solution.

- **Keychain over UserDefaults** for auth tokens — UserDefaults is not encrypted, accessible by other processes on a compromised device
- **Protocol-based DI** over singletons — protocols allow MockAPIClient in tests, singletons make tests impossible to isolate
- **AppError enum** over scattered error handling — one source of truth for all error types across all layers
- **OSLog categories** over `print()` — structured, filterable, zero cost in release builds
- **SwiftLint** enforced at build time — not optional, not a recommendation

---

## Phase 2 — Expanding Beyond iOS

The original guide was iOS-only. The next question was: what if someone wants to build something else?

This led to `21-stacks.md` — the most complex file in the framework.

### The infrastructure expansion problem

First version of the infrastructure section covered only hosting tiers (free, VPS, cloud). The feedback: "this is too limited, not enough infrastructure design variations."

This triggered a complete expansion into architecture patterns:

**Monolith** — draw the diagram, explain when it is the right choice (MVP, 1 developer, under 10k users), explain why starting with microservices is almost always wrong.

**Modular Monolith** — the middle ground that most projects should actually use. Clean module boundaries enforced through DI, but deployed as one unit. Easier to extract a service later if needed.

**Microservices** — full diagram with API Gateway, message broker, independent databases. Documented when it makes sense (20+ person team, independent scaling requirements) and why premature microservices cause more problems than they solve.

**Serverless / Edge** — Cloudflare Workers, Vercel Functions, serverless databases. When cold starts are acceptable, when they are not.

**Event-Driven** — Kafka, RabbitMQ, NATS. When you need to notify many systems from one action. The diagram showing producers, topics, and consumers independently.

**CQRS + Event Sourcing** — documented with the explicit note: this is not for MVPs. High complexity, use only when audit trail and event replay are actual requirements.

**BFF (Backend for Frontend)** — separate API layers optimized per client. iOS gets a different response shape than web, without duplicating backend logic.

Then: database scaling patterns (read replicas, sharding, connection pooling), deployment strategies (Blue/Green, Canary, Rolling, Zero Downtime), infrastructure per product type (MVP diagram, Growth diagram, Enterprise k8s diagram, Mobile app diagram, SaaS multi-tenancy diagram), and security infrastructure.

The golden rule that ended the section: start with a monolith. Migrate to microservices only when a specific part becomes a measurable bottleneck. Not "just in case."

---

## Phase 3 — The Question System

A key insight: documentation alone is not enough. Different developers need completely different guidance.

A senior iOS developer asking "how do I set up the architecture" needs a different answer than a beginner asking the same question.

This created `00-project-type.md` and the 4-question onboarding system embedded in `CLAUDE.md`:

**Q1: Experience level** — determines how Claude explains things. Beginners get more context and simpler choices. Seniors get architecture-level discussion directly.

**Q2: What to build** — determines which stack documentation gets loaded. iOS triggers SwiftUI + MVVM + Keychain + MapKit docs. Web SaaS triggers Next.js + Supabase + Vercel docs.

**Q3: Main constraint** — no budget means free-tier stacks. Speed means opinionated defaults, no options. Scale means architecture discussion first.

**Q4: Design ready** — if Figma link is available, the Figma MCP workflow activates. If not, Claude helps plan the UI before writing any code.

---

## Phase 4 — Development Rules

The development rules in `00b-dev-rules.md` came directly from a real tech lead session.

Five rules stated by the tech lead:
1. Read the docs for the version you are using
2. Study how similar things are already done in the project
3. Propose senior-level solutions, no hacks
4. Test the full flow locally before any MR
5. Do not assume code works — verify

These were not invented for the framework. They were observed in real code review. The additions in the documentation were the "why" behind each rule and the specific tools for verification (`tinker`, `migrate:status`, `docker stats`, Xcode debugger).

The pre-MR checklist of 7 questions at the end of that file is the hardest filter: if any answer is "no," the MR is not ready.

---

## Phase 5 — Turning the Guide into a Framework

The shift from "documentation folder" to "framework" required several components that documentation does not need:

**CLAUDE.md** — the entry point. Claude Code reads this file automatically when a project is opened. Without it, the developer has to manually tell Claude what the project is about every session. With it, Claude knows the rules, the stack defaults, the security requirements, and the onboarding flow the moment the folder opens. This is the most important file in the repository.

**install.sh** — one command that clones the repo, initializes a fresh git history, and copies `.env.example` to `.env`. The goal: zero friction from "I want to use this" to "Claude is asking me questions."

**.claude/settings.json with hooks** — a PreToolUse hook that scans file content for patterns matching API keys (OpenAI `sk-`, AWS `AKIA`, GitHub `ghp_`, Google `AIza`) before any Write or Edit operation. If a pattern matches, the write is blocked and the developer is warned. This runs before the file is touched, not after.

**.gitignore** — not a minimal gitignore. A comprehensive one covering macOS, Xcode, iOS, PHP/Laravel, Node.js, Python, Docker, and all secret file patterns. Generated once, covers everything.

**.env.example** — 40+ variables across every common service category: database, Redis, S3, search, push notifications, payments, OAuth, monitoring, AI, WebSockets. Empty values only. The contract between the template and the developer.

**.mcp.json** — Figma MCP pre-configured. When a developer has a Figma API key, they add it to `.env` and the Figma design-to-code workflow is immediately available.

**templates/** — five project skeletons. Each template contains the minimum files needed to run the stack locally: `docker-compose.yml`, `Dockerfile` (multi-stage where applicable), `.dockerignore`, main config file. The multi-stage Dockerfile pattern (builder stage with all tools, production stage with only runtime) reduces image size from ~800MB to ~200MB.

---

## Phase 6 — GitHub Publication

### Name selection process

Several names were evaluated:

`devforge` — rejected. Over 50 similar repositories on GitHub, would not surface in search.

`keystone` — rejected. KeystoneJS has 10,000 stars and dominates search results. A separate "Keystone Framework for AI coding" also exists.

`foundry` — rejected. The Foundry Ethereum development tool is enormous and owns that search term.

`crucible` — considered. Strong metaphor (raw material + pressure = formed product). Clean in the dev-tools space.

`anvil` — considered. Short, memorable, connects to forge/build metaphor.

`shipyard` — shortlisted. Three layers: (1) a shipyard is where things are built before launch, (2) Docker uses maritime terminology (containers, ports, images), (3) "ship it" is the standard US developer term for releasing a product.

`shipyardMD` — chosen. Adds the MD (markdown) dimension to shipyard. Immediately communicates that this is a markdown documentation framework. Completely unique on GitHub at time of creation.

### Repository configuration

19 topics added for GitHub discoverability: `claude-code`, `claude-ai`, `anthropic`, `ai-framework`, `developer-tools`, `developer-productivity`, `project-template`, `clean-architecture`, `ios-development`, `swift`, `laravel`, `nextjs`, `docker`, `mobile-development`, `saas-starter`, `boilerplate`, `fullstack`, `devops`, `security`.

Issue templates created for bug reports and stack requests.

CONTRIBUTING.md written with explicit rules: English only, official docs links required, templates must run locally.

GITHUB_SETUP.md created with the exact repository description to copy-paste, all topics to add, and recommended communities for initial distribution (Reddit, Hacker News, Product Hunt, Anthropic Discord).

### Post-publication cleanup

Emojis removed from all documentation files after publication. Reason: emojis in technical documentation are an immediately recognizable signal of AI-generated content. They reduce credibility with experienced developers who are the target audience. Plain text with clear structure reads as authored by a person with strong technical writing discipline.

---

## Methods Used During Creation

**Parallel agent execution** — translation of 22 files from Russian to English was split across three simultaneous agents, each handling a non-overlapping set of files. Total translation time: approximately the time of the slowest agent, not the sum of all.

**Incremental documentation** — each problem solved in the real DealHub project was documented immediately after solving it. No reconstruction from memory weeks later. The documentation is accurate because it was written while the error messages were still on screen.

**Pattern before prescription** — every rule in the framework has a "why" behind it. Not "use Keychain" but "use Keychain because UserDefaults is not encrypted and is accessible to any process on a compromised device." The why allows the developer to make the right decision in edge cases the rule does not explicitly cover.

**Negative examples alongside positive** — every guideline includes the wrong way next to the right way. "Bad: `viewModel.data!.first!.id`. Good: guard let." Seeing the wrong pattern prevents the developer from doing it and immediately recognizing it in code review.

**Security as a default, not a step** — security was not added at the end as "and don't forget security." It was embedded from the beginning: the hook runs before any file write, the gitignore is the first file created, the env.example is a required part of the template, and the pre-MR checklist ends with secrets verification.

---

## Conclusions

**What works:** The CLAUDE.md auto-load pattern is the correct abstraction for AI-assisted development frameworks. The developer does not configure anything. They clone and open. The framework activates itself.

**What is underrated:** The 4-question onboarding is more important than all 22 documentation files combined. Without knowing the developer's level and constraints, even perfect documentation produces wrong guidance. The questions make the documentation relevant.

**What is hardest to enforce:** Development discipline rules (read the docs, test the full flow) cannot be technically enforced the way security rules can. The hook stops a secret from being committed. Nothing stops a developer from shipping untested code. The checklist is a reminder, not a gate. This is a human problem that documentation can only address, not solve.

**What would be different if starting over:** The templates would be built first, not last. The templates are what most developers want to copy directly. The documentation explains the decisions inside the templates. Starting with templates and writing documentation to explain them is a more natural order than the reverse.

**The core insight:** Every decision in this framework exists because someone lost hours to a problem that had a known solution. The framework is a collection of "I wish I had known this" moments, organized so the next developer does not have to lose those same hours.
