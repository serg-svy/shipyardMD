# 21 — Full Stack and Infrastructure Matrix

All possible combinations: platform → product type → stack → infrastructure → documentation.

---

## BLOCK 1 — FRONTEND / PLATFORM

---

### iOS Native (Swift)

```
Language: Swift 5.9+
UI: SwiftUI (iOS 16+) / UIKit (legacy)
Architecture: MVVM + Clean Architecture
DI: Protocol-based (see 15-clean-architecture.md)
Navigation: NavigationStack (iOS 16+)
Networking: URLSession + async/await
Local DB: CoreData / SwiftData (iOS 17+)
Build: Xcode 26.4 (17E192) + xcodegen
Linter: SwiftLint
Dependencies: Swift Package Manager (SPM)

Documentation:
 https://developer.apple.com/documentation/swift ← Swift language
 https://developer.apple.com/documentation/swiftui ← SwiftUI
 https://developer.apple.com/tutorials/swiftui ← tutorials
 https://developer.apple.com/documentation/uikit ← UIKit
 https://developer.apple.com/documentation/coredata ← CoreData
 https://developer.apple.com/documentation/swiftdata ← SwiftData
 https://github.com/yonaskolb/XcodeGen ← xcodegen
 https://realm.github.io/SwiftLint/ ← SwiftLint
```

---

### Android Native (Kotlin)

```
Language: Kotlin 2.0+
UI: Jetpack Compose
Architecture: MVVM + Repository + Clean
DI: Hilt (Dagger)
Navigation: Navigation Compose
Networking: Retrofit 2 + OkHttp + Gson/Moshi
Local DB: Room
Async: Coroutines + Flow
Tests: JUnit5 + Mockk + Espresso
Build: Android Studio + Gradle

Documentation:
 https://developer.android.com/jetpack/compose ← Compose
 https://developer.android.com/kotlin ← Kotlin
 https://developer.android.com/topic/architecture ← architecture
 https://developer.android.com/training/dependency-injection/hilt-android ← Hilt
 https://square.github.io/retrofit/ ← Retrofit
 https://developer.android.com/training/data-storage/room ← Room
 https://kotlinlang.org/docs/coroutines-overview.html ← Coroutines
 https://developer.android.com/distribute/console ← Play Console
```

---

### React Native (iOS + Android, JavaScript/TypeScript)

```
Language: TypeScript
UI: React Native + NativeWind (Tailwind for RN)
Navigation: React Navigation 6
State: Zustand / Redux Toolkit
Networking: Axios + React Query (TanStack Query)
Local DB: AsyncStorage / MMKV / WatermelonDB
Push: Firebase Cloud Messaging (FCM)
DI: via React Context + hooks
Build: Expo (simpler) / Bare React Native
IDE: VS Code (works on Windows )

Documentation:
 https://reactnative.dev/docs/getting-started ← React Native
 https://docs.expo.dev/ ← Expo
 https://reactnavigation.org/docs/getting-started ← navigation
 https://tanstack.com/query/latest ← React Query
 https://docs.pmnd.rs/zustand/getting-started/introduction ← Zustand
 https://firebase.google.com/docs/cloud-messaging ← FCM
 https://nativewind.dev/ ← NativeWind

When to choose:
 Team knows JavaScript/TypeScript
 No Mac (Expo works without a Mac for development)
 Need iOS + Android from one codebase
 Complex native features required (ARKit, HealthKit)
```

---

### Flutter (iOS + Android + Web + Desktop)

```
Language: Dart 3+
UI: Flutter Widgets
Architecture: BLoC / Riverpod / GetX
Networking: Dio / http
Local DB: Hive / Isar / Drift (SQLite)
Push: Firebase Cloud Messaging
DI: GetIt / Riverpod
Tests: flutter_test + mocktail
IDE: VS Code / Android Studio (Windows )

Documentation:
 https://docs.flutter.dev/ ← Flutter
 https://dart.dev/guides ← Dart
 https://pub.dev/ ← packages
 https://bloclibrary.dev/ ← BLoC
 https://riverpod.dev/ ← Riverpod
 https://pub.dev/packages/dio ← Dio
 https://docs.hivedb.dev/ ← Hive

When to choose:
 iOS + Android + Web + Desktop from one codebase
 High UI performance required
 Team is ready to learn Dart
 Deep native iOS integration required
```

---

### Next.js (Web Application, SSR/SSG)

```
Language: TypeScript
Framework: Next.js 14+ (App Router)
Styling: Tailwind CSS + shadcn/ui
State: Zustand / Jotai / React Query
Forms: React Hook Form + Zod
Auth: NextAuth.js / Clerk / Supabase Auth
ORM: Prisma / Drizzle
Tests: Jest + React Testing Library + Playwright
Deploy: Vercel (free) / Railway / Coolify

Documentation:
 https://nextjs.org/docs ← Next.js
 https://tailwindcss.com/docs ← Tailwind
 https://ui.shadcn.com/docs ← shadcn/ui
 https://react-hook-form.com/ ← forms
 https://zod.dev/ ← validation
 https://next-auth.js.org/ ← NextAuth
 https://www.prisma.io/docs/ ← Prisma ORM
 https://orm.drizzle.team/ ← Drizzle ORM
 https://playwright.dev/ ← E2E tests
```

---

### Nuxt.js (Vue Stack, Web)

```
Language: TypeScript
Framework: Nuxt 3
Styling: Tailwind CSS + NuxtUI / Vuetify
State: Pinia
Networking: $fetch / ofetch
Auth: nuxt-auth / Supabase
ORM: Prisma / Drizzle
Deploy: Vercel / Netlify / Coolify

Documentation:
 https://nuxt.com/docs ← Nuxt 3
 https://vuejs.org/guide/ ← Vue 3
 https://pinia.vuejs.org/ ← Pinia
 https://ui.nuxt.com/ ← NuxtUI
```

---

### SvelteKit (Web, Minimalist)

```
Language: TypeScript
Framework: SvelteKit
Styling: Tailwind CSS
State: Svelte built-in stores
Auth: Lucia Auth / Auth.js
ORM: Prisma / Drizzle
Deploy: Vercel / Netlify / Cloudflare Pages

Documentation:
 https://kit.svelte.dev/docs ← SvelteKit
 https://svelte.dev/docs ← Svelte
 https://lucia-auth.com/ ← Lucia Auth
```

---

### Angular (Enterprise Web)

```
Language: TypeScript
Framework: Angular 17+
Styling: Angular Material / PrimeNG
State: NgRx / Signals
Networking: HttpClient (built-in)
DI: Angular built-in DI
Tests: Karma + Jasmine / Jest
Deploy: AWS / Azure / Firebase Hosting

Documentation:
 https://angular.dev/overview ← Angular
 https://ngrx.io/ ← NgRx
 https://material.angular.io/ ← Angular Material

When to choose:
 Enterprise project with a large team
 Strict typing and architecture matter
 Client requires Angular
```

---

### WordPress (Site with or without Code)

```
No-code / Low-code path:
 CMS: WordPress 6+
 Hosting: SpinupWP, Kinsta, WP Engine / VPS Hetzner
 Theme: Astra + Elementor / GeneratePress + custom
 Plugins: ACF Pro, WooCommerce, Yoast SEO, WP Rocket
 Deploy: Git + WP Pusher / Bedrock + Deployer

Custom Theme path:
 PHP: WordPress PHP API
 Build: Webpack / Vite + SCSS
 ACF: custom fields for any content type
 REST API: WordPress REST API → React/Vue frontend

Documentation:
 https://developer.wordpress.org/ ← Dev portal
 https://developer.wordpress.org/themes/ ← Themes
 https://developer.wordpress.org/plugins/ ← Plugins
 https://developer.wordpress.org/rest-api/ ← REST API
 https://www.advancedcustomfields.com/resources/ ← ACF Pro
 https://woocommerce.com/documentation/ ← WooCommerce
 https://roots.io/bedrock/ ← Bedrock (modern WP)
 https://yoast.com/wordpress/plugins/seo/ ← Yoast SEO
 https://wp-rocket.me/documentation/ ← WP Rocket cache
```

---

### Shopify (E-commerce without Code)

```
Platform: Shopify
Themes: Liquid (Shopify template engine) + Dawn theme
Extensions: Shopify Apps (from the marketplace)
Custom: Shopify CLI + Liquid + JavaScript

Documentation:
 https://shopify.dev/docs/themes ← Liquid themes
 https://shopify.dev/docs/apps ← Shopify Apps
 https://shopify.dev/docs/api/storefront ← Storefront API
 https://polaris.shopify.com/ ← Polaris UI

When to choose:
 Online store only, nothing else needed
 Client wants to manage products themselves
 No budget for building from scratch
```

---

### Webflow (No-code, Visual Development)

```
Platform: Webflow
CMS: Webflow CMS
Logic: Webflow Logic (automations)
Hosting: built into Webflow

Documentation:
 https://university.webflow.com/ ← Webflow University
 https://webflow.com/made-in-webflow ← examples
 https://webflow.com/feature/logic ← Logic

When to choose:
 Complex design, animations
 No developer available
 Fast result needed
```

---

### Telegram Mini App / Bot

```
Bot (Python):
 Library: python-telegram-bot / aiogram
 Language: Python 3.11+
 Hosting: Railway / Render / VPS

Bot (Node.js):
 Library: Grammy / Telegraf
 Language: TypeScript

Mini App (React):
 UI: React + Telegram Web App API
 Styling: Tailwind
 Backend: FastAPI / Express
 DB: PostgreSQL / SQLite

Documentation:
 https://core.telegram.org/bots/api ← Bot API
 https://core.telegram.org/bots/webapps ← Mini Apps API
 https://docs.python-telegram-bot.org/ ← python-telegram-bot
 https://aiogram.dev/ ← aiogram
 https://grammy.dev/ ← Grammy (Node)
 https://telegraf.js.org/ ← Telegraf (Node)
```

---

### Desktop App (macOS / Windows / Linux)

```
Electron (Web Technologies):
 Language: TypeScript + React/Vue
 Build: Electron Builder
 Documentation: https://www.electronjs.org/docs

Tauri (Rust + Web Technologies):
 Language: Rust + TypeScript + React/Vue
 Advantages: smaller size, faster, more secure than Electron
 Documentation: https://tauri.app/v1/guides/

macOS Native (Swift):
 Language: Swift + SwiftUI
 Documentation: https://developer.apple.com/macos/
```

---

## BLOCK 2 — BACKEND

---

### Laravel (PHP) — Recommended

```
Version: Laravel 11
Language: PHP 8.3+
ORM: Eloquent
Auth: Laravel Sanctum (API tokens) / Fortify
Queues: Redis + Laravel Horizon
Search: Laravel Scout + Meilisearch
Files: Spatie MediaLibrary + S3/MinIO
Roles: Spatie Permission
Audit: Spatie ActivityLog
Tests: PHPUnit + Pest

Documentation:
 https://laravel.com/docs/11.x ← Laravel 11
 https://laravel.com/docs/sanctum ← Sanctum Auth
 https://laravel.com/docs/queues ← Queues
 https://spatie.be/docs/laravel-medialibrary ← MediaLibrary
 https://spatie.be/docs/laravel-permission ← Roles/Permissions
 https://spatie.be/docs/laravel-query-builder ← Query Builder
 https://pestphp.com/ ← Pest tests
```

---

### Node.js / Express (JavaScript)

```
Runtime: Node.js 20 LTS
Framework: Express 5 / Fastify / Hono
Language: TypeScript
ORM: Prisma / Drizzle / TypeORM
Auth: JWT (jsonwebtoken) / Passport.js
Validation: Zod / Joi
Tests: Jest + Supertest

Documentation:
 https://expressjs.com/ ← Express
 https://fastify.dev/docs/ ← Fastify
 https://www.prisma.io/docs/ ← Prisma
 https://orm.drizzle.team/ ← Drizzle
```

---

### NestJS (Node.js, Enterprise)

```
Framework: NestJS
Language: TypeScript
ORM: TypeORM / Prisma / MikroORM
Auth: Passport + JWT / Guards
Queues: Bull / BullMQ
WebSockets: @nestjs/websockets + Socket.io
Swagger: @nestjs/swagger (auto-documentation)
Tests: Jest + built-in Test module

Documentation:
 https://docs.nestjs.com/ ← NestJS
 https://docs.nestjs.com/websockets/gateways ← WebSockets
 https://docs.nestjs.com/openapi/introduction ← Swagger
 https://docs.bullmq.io/ ← BullMQ

When to choose:
 Large project with a team
 Strict out-of-the-box architecture needed
 Already know Angular — the architecture is similar
```

---

### Python / FastAPI

```
Framework: FastAPI
Language: Python 3.11+
ORM: SQLAlchemy 2 + Alembic (migrations)
Auth: python-jose (JWT) + passlib
Validation: Pydantic v2
Queues: Celery + Redis
Tests: pytest + httpx

Documentation:
 https://fastapi.tiangolo.com/ ← FastAPI
 https://docs.sqlalchemy.org/ ← SQLAlchemy
 https://docs.celeryq.dev/ ← Celery
 https://pydantic-docs.helpmanual.io/ ← Pydantic

When to choose:
 ML/AI functionality in the same service
 Team knows Python
 Scientific / analytical product
```

---

### Django (Python, Full-stack)

```
Framework: Django 5 + DRF (Django Rest Framework)
ORM: Django ORM built-in
Auth: Django Auth + DRF JWT / dj-rest-auth
Admin: Django Admin (free admin panel out of the box!)
Queues: Celery + Redis
Tests: pytest-django

Documentation:
 https://docs.djangoproject.com/ ← Django
 https://www.django-rest-framework.org/ ← DRF
 https://django-rest-framework-simplejwt.readthedocs.io/ ← JWT

When to choose:
 Need a ready-made admin panel (Django Admin — best out of the box)
 Monolith: site + API in one
 Team knows Python
```

---

### Go (Golang) — High Load

```
Framework: Gin / Echo / Fiber / Chi
ORM: GORM / sqlx / sqlc
Auth: JWT
Queues: Asynq / NATS
Tests: built-in testing + testify

Documentation:
 https://go.dev/doc/ ← Go
 https://gin-gonic.com/docs/ ← Gin
 https://gorm.io/docs/ ← GORM
 https://sqlc.dev/ ← sqlc

When to choose:
 Very high load (100k+ RPS)
 Microservices
 Team knows Go
```

---

### Backend-as-a-Service (No Own Server)

```
Supabase (recommended — open source Firebase):
 DB: PostgreSQL (full access!)
 Auth: built-in (email, phone, OAuth)
 Storage: S3-compatible storage
 Realtime: WebSockets out of the box
 Edge Fn: Deno functions (like Lambda)
 Free: 500 MB DB, 1 GB Storage, 50k users
 Documentation: https://supabase.com/docs

Firebase (Google):
 DB: Firestore (NoSQL) / Realtime Database
 Auth: Firebase Auth (SMS, email, OAuth)
 Storage: Firebase Storage
 Push: FCM (best for push notifications)
 Analytics: Firebase Analytics
 Crashlytics: crash monitoring
 Free: generous free tier
 Documentation: https://firebase.google.com/docs

Pocketbase (self-hosted, single binary):
 DB: SQLite built-in
 Auth: built-in
 Storage: built-in
 Run: single file, no Docker needed
 Documentation: https://pocketbase.io/docs/

Appwrite (self-hosted, open source):
 Documentation: https://appwrite.io/docs
```

---

## BLOCK 3 — DATABASE

```
PostgreSQL (recommended):
 + ACID, JSON fields, PostGIS for geolocation
 + Extensions: pgvector (AI), pg_trgm (search)
 Documentation: https://www.postgresql.org/docs/

MySQL / MariaDB:
 + Popular with PHP/WordPress
 + Simple hosting everywhere
 Documentation: https://dev.mysql.com/doc/

MongoDB (NoSQL):
 + Flexible schema, horizontal scaling
 + Good for unstructured data
 Documentation: https://www.mongodb.com/docs/

SQLite:
 + No server, single file
 + Ideal for mobile apps, bots
 Documentation: https://www.sqlite.org/docs.html

Redis:
 + In-memory, cache, queues, sessions, pub/sub
 + Does not replace a primary database
 Documentation: https://redis.io/docs/

Planetscale (MySQL serverless):
 Documentation: https://planetscale.com/docs

Neon (PostgreSQL serverless):
 Documentation: https://neon.tech/docs

Turso (SQLite serverless + edge):
 Documentation: https://docs.turso.tech/
```

---

## BLOCK 4 — INFRASTRUCTURE AND HOSTING

```
┌─────────────────────────────────────────────────────────────────┐
│ COMPLEXITY LEVEL → FREE → SIMPLE → FLEXIBLE → MAXIMUM │
└─────────────────────────────────────────────────────────────────┘

FREE (for getting started and learning):
 Vercel — Next.js, frontend, Edge Functions
 https://vercel.com/docs
 Railway — any backend, DB, free up to $5 traffic
 https://docs.railway.app/
 Render — web services, PostgreSQL, Redis (free tier)
 https://render.com/docs
 Fly.io — Docker containers, global deploy
 https://fly.io/docs/
 Supabase — DB + Auth + Storage, free tier
 https://supabase.com/docs
 Cloudflare Pages — static files + Workers (Edge Functions)
 https://developers.cloudflare.com/pages/

SIMPLE (VPS, $4–20/month):
 Hetzner — best price-to-quality ratio in Europe
 https://docs.hetzner.com/
 DigitalOcean — Droplets, managed DB, App Platform
 https://docs.digitalocean.com/
 Linode (Akamai) — VPS, Object Storage
 https://www.linode.com/docs/

FLEXIBLE (Cloud, pay-per-use):
 AWS — EC2, RDS, S3, CloudFront, Lambda, SES
 https://docs.aws.amazon.com/
 Google Cloud — Cloud Run, Cloud SQL, GCS, Firebase
 https://cloud.google.com/docs
 Azure — App Service, SQL, Blob Storage
 https://learn.microsoft.com/azure/

SELF-HOSTED (Docker on your own server):
 Coolify — self-hosted Heroku, managed via UI
 https://coolify.io/docs/
 Portainer — Docker container management
 https://docs.portainer.io/
 Caprover — PaaS on your own VPS
 https://caprover.com/docs/

DEPLOY AND CI/CD:
 GitHub Actions — free for public repos
 https://docs.github.com/en/actions
 GitLab CI — built into GitLab
 https://docs.gitlab.com/ee/ci/
 Dokku — mini-Heroku on your own VPS
 https://dokku.com/docs/
```

---

## BLOCK 5 — SERVICES (by category)

```
AUTH / SSO:
 Auth0 — ready-made auth for any stack
 https://auth0.com/docs
 Clerk — auth for Next.js/React
 https://clerk.com/docs
 Keycloak — self-hosted, enterprise SSO
 https://www.keycloak.org/documentation

SMS / OTP:
 Twilio — SMS, Voice, Verify API (paid)
 https://www.twilio.com/docs
 Firebase Auth — SMS verification (free up to limit)
 https://firebase.google.com/docs/auth
 AWS SNS — SMS via Amazon
 https://docs.aws.amazon.com/sns/
 Vonage (Nexmo) — SMS API
 https://developer.vonage.com/

EMAIL:
 Resend — Email API for developers (3k/month free)
 https://resend.com/docs
 Postmark — transactional emails
 https://postmarkapp.com/developer
 SendGrid — bulk email + transactional
 https://docs.sendgrid.com/
 AWS SES — cheapest at volume
 https://docs.aws.amazon.com/ses/
 Mailgun — https://documentation.mailgun.com/

PAYMENTS:
 Stripe — best API, works everywhere
 https://stripe.com/docs
 LiqPay — Ukraine/CIS
 https://www.liqpay.ua/documentation/
 Apple Pay — native on iOS via PassKit
 https://developer.apple.com/documentation/passkit
 Google Pay — native on Android
 https://developers.google.com/pay/api
 StoreKit 2 — in-app purchases iOS
 https://developer.apple.com/documentation/storekit
 RevenueCat — subscription management iOS+Android
 https://docs.revenuecat.com/

FILE STORAGE:
 AWS S3 — industry standard
 https://docs.aws.amazon.com/s3/
 Cloudflare R2 — like S3 but no egress fees
 https://developers.cloudflare.com/r2/
 MinIO — self-hosted S3-compatible
 https://min.io/docs/
 Supabase Storage — 1 GB free
 https://supabase.com/docs/guides/storage
 Backblaze B2 — cheaper than S3, S3-compatible
 https://www.backblaze.com/docs/

SEARCH:
 Meilisearch — fast, open source, easy to run
 https://www.meilisearch.com/docs
 Requires MEILI_MASTER_KEY even locally
 Algolia — managed, expensive but powerful
 https://www.algolia.com/doc/
 Typesense — open source Algolia alternative
 https://typesense.org/docs/
 PostgreSQL FTS — full-text search built into PG
 https://www.postgresql.org/docs/current/textsearch.html

PUSH NOTIFICATIONS:
 APNs — iOS only, directly from Apple
 https://developer.apple.com/documentation/usernotifications
 FCM — iOS + Android via Firebase
 https://firebase.google.com/docs/cloud-messaging
 OneSignal — multi-platform, free tier
 https://documentation.onesignal.com/
 Expo Push — for React Native + Expo
 https://docs.expo.dev/push-notifications/overview/

MONITORING / ERRORS:
 Sentry — errors, performance
 https://docs.sentry.io/
 Firebase Crashlytics — iOS/Android crashes
 https://firebase.google.com/docs/crashlytics
 Datadog — enterprise monitoring
 https://docs.datadoghq.com/
 Grafana + Prometheus — self-hosted, free
 https://grafana.com/docs/

ANALYTICS:
 Firebase Analytics — mobile analytics, free
 https://firebase.google.com/docs/analytics
 Amplitude — product analytics
 https://www.docs.amplitude.com/
 Mixpanel — event-based analytics
 https://docs.mixpanel.com/
 PostHog — self-hosted product analytics
 https://posthog.com/docs

CDN:
 Cloudflare — free CDN + DDoS protection
 https://developers.cloudflare.com/
 AWS CloudFront — CDN for AWS
 https://docs.aws.amazon.com/cloudfront/
 BunnyCDN — cheaper, faster
 https://docs.bunny.net/

MAPS:
 Google Maps — paid after the free limit
 https://developers.google.com/maps/documentation
 MapKit (Apple) — free for iOS
 https://developer.apple.com/documentation/mapkit
 Mapbox — flexible, stylish maps
 https://docs.mapbox.com/
 OpenStreetMap + Leaflet — free for web
 https://leafletjs.com/reference.html

VIDEO / CALLS:
 Agora — WebRTC, video calls
 https://docs.agora.io/
 Daily.co — video call API
 https://docs.daily.co/
 Twilio Video — WebRTC
 https://www.twilio.com/docs/video
 Mux — video streaming, processing
 https://docs.mux.com/
 Cloudflare Stream — video hosting
 https://developers.cloudflare.com/stream/

AI / ML:
 OpenAI API — GPT, DALL-E, Whisper
 https://platform.openai.com/docs/
 Anthropic API — Claude
 https://docs.anthropic.com/
 Vercel AI SDK — AI for Next.js
 https://sdk.vercel.ai/docs
 Replicate — open source models via API
 https://replicate.com/docs
```

---

## BLOCK 5b — QUEUES AND BACKGROUND PROCESSING

```
Redis + Laravel Horizon (PHP):
 + Queues, delayed jobs, monitoring via web UI
 Documentation: https://laravel.com/docs/horizon

Bull / BullMQ (Node.js):
 + Redis-based queues, retries, dead letter
 Documentation: https://docs.bullmq.io/

Celery (Python):
 + Async tasks, periodic tasks (beat scheduler)
 Documentation: https://docs.celeryq.dev/

Sidekiq (Ruby):
 + Fast background jobs
 Documentation: https://sidekiq.org/

RabbitMQ (message broker):
 + More powerful than Redis for queues, routing
 Documentation: https://www.rabbitmq.com/documentation.html

Apache Kafka (Event Streaming):
 + Millions of messages/sec, storage, event replay
 + For event-driven architecture at serious scale
 Documentation: https://kafka.apache.org/documentation/

NATS (lightweight broker):
 + Simple, fast, for Go microservices
 Documentation: https://docs.nats.io/
```

---

## BLOCK 5c — REALTIME

```
Laravel Reverb (WebSockets, PHP):
 + Official WebSocket server for Laravel
 Documentation: https://laravel.com/docs/reverb

Soketi (self-hosted Pusher):
 + Compatible with the Pusher API, runs on your own VPS
 Documentation: https://docs.soketi.app/

Pusher (managed):
 + Managed WebSockets, free up to 200 connections
 Documentation: https://pusher.com/docs/channels/

Socket.io (Node.js):
 + WebSockets + fallback to long polling
 Documentation: https://socket.io/docs/v4/

Ably (managed realtime):
 + Managed pub/sub, WebSockets, SSE
 Documentation: https://ably.com/docs

Server-Sent Events (SSE):
 + One-way events from server (simpler than WebSockets)
 + Ideal for live feeds, notifications
 Documentation: https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
```

---

## BLOCK 6 — INFRASTRUCTURE ARCHITECTURE PATTERNS

---

### Monolith

```
┌─────────────────────────────────────────────┐
│ USERS │
└──────────────────┬──────────────────────────┘
 │ HTTP
┌──────────────────▼──────────────────────────┐
│ Nginx / Reverse Proxy │
│ (SSL termination, static files) │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ MONOLITH (single process) │
│ ┌──────────┐ ┌──────────┐ ┌────────────┐ │
│ │ Auth │ │Listings │ │ Chat │ │
│ └──────────┘ └──────────┘ └────────────┘ │
│ ┌──────────┐ ┌──────────┐ ┌────────────┐ │
│ │ Search │ │ Media │ │Notifications│ │
│ └──────────┘ └──────────┘ └────────────┘ │
└──────────────────┬──────────────────────────┘
 ┌─────────┼──────────┐
 ▼ ▼ ▼
 PostgreSQL Redis MinIO/S3

When to use:
 Startup / MVP — fast to develop
 Team of 1–5 people
 < 10k users
 No complex independent modules

Pros: Simple deploy, no network latency between modules
Cons: One module crashes — everything crashes; hard to scale parts
```

---

### Modular Monolith

```
┌─────────────────────────────────────────────┐
│ USERS │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ Nginx / Load Balancer │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ MONOLITH (with module boundaries) │
│ ┌─────────────────────────────────────┐ │
│ │ Modules (isolated via DI) │ │
│ │ Auth | Listings | Chat | Payments │ │
│ │ Each module: Controller + │ │
│ │ Service + Repository + Event │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ Internal Event Bus (synchronous) │ │
│ └─────────────────────────────────────┘ │
└──────────────────┬──────────────────────────┘
 ┌─────────┼──────────┐
 ▼ ▼ ▼
 PostgreSQL Redis S3/MinIO

When to use:
 Planning to grow to microservices but it's too early
 Team of 5–15 people
 Business domains are already clearly defined

Pros: Can extract a module into a service without rewriting
Cons: Requires discipline — don't mix modules
```

---

### Microservices

```
┌─────────────────────────────────────────────┐
│ USERS │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ API Gateway (Kong / Nginx) │
│ (auth, rate limit, routing, logging) │
└──┬───────┬───────┬───────┬────────┬─────────┘
 │ │ │ │ │
 ▼ ▼ ▼ ▼ ▼
┌──────┐ ┌─────┐ ┌─────┐ ┌──────┐ ┌──────┐
│ Auth │ │List-│ │Chat │ │Notif-│ │Media │
│ svc │ │ings │ │ svc │ │icat. │ │ svc │
└──┬───┘ └──┬──┘ └──┬──┘ └──┬───┘ └──┬───┘
 │ │ │ │ │
 ▼ ▼ ▼ ▼ ▼
 users_db list_db chat_db redis S3/MinIO
 │
 ┌────────▼────────┐
 │ Message Broker │
 │ (Kafka/RabbitMQ)│
 └─────────────────┘

When to use:
 Team of 20+ people, different teams for different services
 Different services need to scale independently
 Different languages/stacks for different tasks

Pros: Independent deploy, scale parts of the system
Cons: Ops complexity, network latency, distributed tracing required
```

---

### Serverless / Edge Functions

```
┌─────────────────────────────────────────────┐
│ USERS │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ CDN / Edge (Cloudflare / Vercel Edge) │
│ (static cache, edge middleware, geo-routing)│
└──┬───────────────┬──────────────────────────┘
 │ │
 ▼ ▼
┌──────────────┐ ┌─────────────────────────────┐
│ Static Files │ │ Serverless Functions │
│ (HTML/CSS/JS)│ │ (Lambda / CF Workers / │
│ │ │ Vercel Functions) │
└──────────────┘ └──────┬──────────────────────┘
 │
 ┌──────────┼──────────┐
 ▼ ▼ ▼
 PlanetScale Neon DB Redis
 (serverless) (Postgres (Upstash)
 serverless)

When to use:
 No constant traffic (pay per invocation)
 Global deploy (edge = closer to the user)
 Next.js / SvelteKit / Astro project

Pros: Auto-scaling, no server to maintain
Cons: Cold start latency, execution limits, expensive at constant traffic
```

---

### Event-Driven Architecture

```
┌─────────────────────────────────────────────┐
│ PRODUCERS │
│ (API services that create events) │
│ Listing Created → Payment Completed → etc │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ EVENT BROKER │
│ Kafka / RabbitMQ / NATS │
│ │
│ Topics: listing.created, payment.done, │
│ user.registered, message.sent │
└──┬───────────┬──────────┬────────────┬──────┘
 │ │ │ │
 ▼ ▼ ▼ ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐
│Notif.│ │Search│ │Email │ │Analytics │
│svc │ │index │ │svc │ │svc │
└──────┘ └──────┘ └──────┘ └──────────┘
CONSUMERS (react to events independently)

When to use:
 Need to notify many systems on a single action
 Need ordering and reliable delivery
 Audit and event replay matter

Pros: Low coupling, reliable delivery, scales well
Cons: Hard to debug, eventual consistency, broker required
```

---

### CQRS + Event Sourcing

```
┌───────────────────────────────────────────┐
│ CLIENT │
└──────────┬────────────────────────────────┘
 │
 ┌──────┴──────┐
 │ │
 ▼ ▼
┌────────┐ ┌────────┐
│COMMAND │ │ QUERY │
│ side │ │ side │
│(write) │ │ (read) │
└───┬────┘ └───┬────┘
 │ │
 ▼ ▼
┌────────┐ ┌────────────────┐
│ Event │ │ Read Models │
│ Store │──▶│ (optimized │
│(append │ │ for queries) │
│ only) │ │ Elasticsearch │
└────────┘ │ / Redis Cache │
 └────────────────┘

When to use:
 Full history of changes required (finance, audit)
 Read and write loads differ significantly
 Complex business rules

Cons: High complexity — NOT for an MVP
```

---

### BFF — Backend for Frontend

```
┌──────────┐ ┌──────────┐ ┌──────────┐
│ iOS App │ │ Android │ │ Web │
└────┬─────┘ └────┬─────┘ └────┬─────┘
 │ │ │
 ▼ ▼ ▼
┌─────────┐ ┌─────────┐ ┌──────────┐
│ BFF iOS │ │BFF Droid│ │ BFF Web │
│(GraphQL │ │(REST │ │(REST + │
│or REST) │ │optimiz.)│ │ SSR) │
└────┬────┘ └────┬────┘ └────┬─────┘
 └───────────┴───────────┘
 │
 ┌───────────┴───────────┐
 ▼ ▼ ▼
 Auth svc Listing svc Chat svc

When to use:
 Different clients need different response formats
 iOS needs less data than web
 Traffic optimization for mobile devices
```

---

## BLOCK 7 — DATABASE SCALING PATTERNS

```
READ REPLICAS (separate reads and writes):
 ┌──────────────────────────┐
 │ APPLICATION │
 └──┬───────────────────┬───┘
 │ WRITE │ READ
 ▼ ▼
 ┌──────────┐ ┌──────────────────┐
 │ Primary │───▶│ Read Replica x N │
 │(writes) │ │ (reads, reports) │
 └──────────┘ └──────────────────┘

 Laravel: config/database.php → 'read' / 'write' connections
 Documentation: https://laravel.com/docs/database#read-write-connections

DATABASE SHARDING (horizontal partitioning):
 User 1–1M → Shard 1 (PostgreSQL instance 1)
 User 1M–2M → Shard 2 (PostgreSQL instance 2)
 Requires a shard coordinator (Citus / Vitess)
 Citus docs: https://docs.citusdata.com/

CONNECTION POOLING (PgBouncer):
 + Reduces the number of real connections to PostgreSQL
 + Critical when > 100 simultaneous connections
 Documentation: https://www.pgbouncer.org/

DATA CACHING:
 ┌────────────────────────────────────┐
 │ Cache levels (fast → slow) │
 │ │
 │ L1: In-memory (PHP array, RAM) │
 │ L2: Redis (shared between workers) │
 │ L3: CDN (static files, API responses)│
 │ L4: PostgreSQL (query cache) │
 └────────────────────────────────────┘

 Redis cache in Laravel:
 Cache::remember('listings:page:1', 3600, fn() => ...)
 Cache::tags(['listings'])->flush(); // flush on change
 Documentation: https://laravel.com/docs/cache
```

---

## BLOCK 8 — DEPLOYMENT STRATEGIES

```
BLUE / GREEN DEPLOYMENT:
 ┌──────────┐ ┌──────────┐
 │ Blue │ LIVE │ Green │ IDLE
 │(v1.0) │◀── ─ ─ │(v1.1) │
 └──────────┘ │ └──────────┘
 Load │
 Balan-│
 cer │
 └── switch traffic →
 ┌──────────┐ ┌──────────┐
 │ Blue │ IDLE │ Green │ LIVE
 │(v1.0) │ │(v1.1) │◀──
 └──────────┘ └──────────┘

 + Instant rollback (switch back)
 + No downtime
 - Requires 2x resources during deploy

CANARY RELEASE:
 100% → 5% new version → 20% → 50% → 100%
 + Gradual testing on real users
 + Rollback if error rate increases
 Nginx: upstream { server v1 weight=95; server v2 weight=5; }

ROLLING UPDATE (Kubernetes):
 Pod v1, v1, v1, v1
 → Pod v2, v1, v1, v1
 → Pod v2, v2, v1, v1
 → Pod v2, v2, v2, v2
 + No downtime, gradual
 Documentation: https://kubernetes.io/docs/tutorials/kubernetes-basics/update/

ZERO DOWNTIME LARAVEL:
 1. php artisan down --retry=60 # maintenance mode
 2. git pull
 3. composer install --no-dev
 4. php artisan migrate # only backwards-compatible!
 5. php artisan config:cache
 6. php artisan up
 Or: Deployer — https://deployer.org/docs/7.x/

DOCKER + WATCHTOWER (auto-update):
 Watchtower checks Docker Hub → updates containers automatically
 Documentation: https://containrrr.dev/watchtower/
```

---

## BLOCK 9 — INFRASTRUCTURE BY PRODUCT TYPE

---

### MVP / Startup (0 → 1,000 Users)

```
Goal: fast, cheap, works

┌─────────────────────────────────────────┐
│ Hetzner VPS (€4/month) │
│ ┌──────────────────────────────────┐ │
│ │ Docker Compose │ │
│ │ ┌──────┐ ┌──────┐ ┌──────────┐ │ │
│ │ │Nginx │ │ App │ │PostgreSQL│ │ │
│ │ │+SSL │ │Laravel│ │+ Redis │ │ │
│ │ └──────┘ └──────┘ └──────────┘ │ │
│ │ ┌──────────────────────────────┐│ │
│ │ │ MinIO (files) optional ││ │
│ │ └──────────────────────────────┘│ │
│ └──────────────────────────────────┘ │
└─────────────────────────────────────────┘
 │
Cloudflare (DNS + CDN + DDoS free)

Deploy: GitHub Actions → SSH → docker compose up -d
Backups: pg_dump → Backblaze B2 (automatically via cron)
Monitoring: UptimeRobot (free) + Sentry (free tier)
```

---

### Growth (1k → 50k Users)

```
┌────────────────────────────────────────────────┐
│ Cloudflare (CDN + DDoS + DNS) │
└────────────────┬───────────────────────────────┘
 │
┌────────────────▼───────────────────────────────┐
│ Load Balancer (Hetzner LB or Nginx) │
└────┬───────────────────────┬───────────────────┘
 │ │
┌────▼──────┐ ┌──────▼──────┐
│ App #1 │ │ App #2 │
│ (Laravel) │ │ (Laravel) │
└────┬──────┘ └──────┬──────┘
 └──────────┬────────────┘
 │
 ┌───────────┼────────────┐
 ▼ ▼ ▼
┌────────┐ ┌──────┐ ┌─────────┐
│Primary │ │Redis │ │Meilisrch│
│ PG │ │Cache │ │(search) │
│+Replica│ └──────┘ └─────────┘
└────────┘
 ┌──────────────┐
 │ Backblaze B2 │
 │ or Cloudfl. │
 │ R2 (files) │
 └──────────────┘

CI/CD: GitHub Actions → Docker Registry → deploy via SSH
Backups: automated + test restore every month
```

---

### Enterprise / High Load (50k+)

```
┌─────────────────────────────────────────────┐
│ Cloudflare Enterprise │
└──────────────────┬──────────────────────────┘
 │
┌──────────────────▼──────────────────────────┐
│ Kubernetes (k8s) │
│ AWS EKS / GKE / Hetzner k3s │
│ ┌─────────────────────────────────────┐ │
│ │ Pods: API | Workers | WebSockets │ │
│ │ HPA (Horizontal Pod Autoscaler) │ │
│ └─────────────────────────────────────┘ │
└──────────────────┬──────────────────────────┘
 ┌─────────┼──────────────┐
 ▼ ▼ ▼
 AWS RDS ElastiCache Elasticsearch
 (PG Multi- (Redis cluster) (or Typesense)
 AZ + read
 replicas)
 ┌────────────┐
 │ AWS S3 + │
 │ CloudFront │
 └────────────┘

Monitoring: Datadog / Grafana + Prometheus + Jaeger (tracing)
CI/CD: GitHub Actions → ECR → ArgoCD (GitOps)
k8s documentation: https://kubernetes.io/docs/home/
ArgoCD documentation: https://argo-cd.readthedocs.io/
```

---

### Mobile App (iOS/Android + Backend)

```
┌──────────────────────────────────────────────┐
│ Mobile Apps (iOS / Android) │
│ ┌────────────────────────────────────┐ │
│ │ Retry logic + offline cache │ │
│ │ Certificate pinning (optional) │ │
│ └────────────────────────────────────┘ │
└──────────────┬───────────────────────────────┘
 │ HTTPS (Sanctum token)
┌──────────────▼───────────────────────────────┐
│ Cloudflare (WAF + CDN) │
└──────────────┬───────────────────────────────┘
 │
┌──────────────▼───────────────────────────────┐
│ Nginx (rate limiting, SSL termination) │
└──────────────┬───────────────────────────────┘
 │
┌──────────────▼───────────────────────────────┐
│ Laravel API (v1, v2 versioning) │
│ ┌─────────────────────────────────────────┐ │
│ │ Queue Workers (separate processes) │ │
│ │ Horizon Dashboard │ │
│ └─────────────────────────────────────────┘ │
└──────────────┬───────────────────────────────┘
 ┌─────────┼──────────┬─────────┐
 ▼ ▼ ▼ ▼
 PostgreSQL Redis MinIO/S3 APNs/FCM
 (push notifications)
```

---

### SaaS (with Multi-tenancy)

```
MULTI-TENANCY APPROACHES:

1. SINGLE INSTANCE — SEPARATE SCHEMAS (PostgreSQL schemas):
 tenant_acme.users | tenant_globex.users
 + Data isolation
 - Complex migrations

2. SINGLE INSTANCE — tenant_id IN TABLES:
 users (id, tenant_id, email, ...)
 + Simple, Laravel: GlobalScope automatically
 - Data leak risk if a query has a bug

3. SEPARATE DATABASE PER TENANT:
 + Full isolation, individual backups
 - Expensive with many tenants

Laravel Multitenancy package (Spatie):
 Documentation: https://spatie.be/docs/laravel-multitenancy

Infrastructure:
 ┌─────────────────────────────────────────┐
 │ acme.yoursaas.com │
 │ globex.yoursaas.com │
 │ ↓ Nginx identifies tenant by domain │
 └────────────────┬────────────────────────┘
 │
 ┌───────▼────────┐
 │ Laravel App │
 │ TenantMiddlwr │
 └───────┬────────┘
 │
 ┌────────────┼────────────┐
 ▼ ▼ ▼
 DB tenant1 DB tenant2 DB tenantN
```

---

## BLOCK 10 — INFRASTRUCTURE SECURITY

```
NETWORK PERIMETER:
 Cloudflare WAF — block attacks at the CDN level
 Fail2Ban — ban IP after N failed requests
 UFW / iptables — close all ports except 80/443/SSH
 SSH key-only — disable password authentication

SECRETS:
 .env — never in git
 Docker secrets — for production
 HashiCorp Vault — enterprise secret management
 https://developer.hashicorp.com/vault/docs
 AWS Secrets Manager — managed option
 https://docs.aws.amazon.com/secretsmanager/

RATE LIMITING:
 Nginx: limit_req_zone, limit_req
 Laravel: throttle middleware (60 req/min)
 Cloudflare: Rate Limiting rules

HTTPS / SSL:
 Let's Encrypt — free TLS (certbot)
 https://certbot.eff.org/
 Cloudflare SSL — free via Cloudflare proxy

BACKUPS:
 3-2-1 rule:
 3 copies of data
 2 different media (VPS disk + Backblaze)
 1 offsite (different region/provider)

 pg_dump → encrypt (gpg) → Backblaze B2
 Test restore — once a month, mandatory!
```

---

## BLOCK 11 — ARCHITECTURE SELECTION MATRIX

```
┌────────────────┬──────────────────────────────────┐
│ Situation │ Recommendation │
├────────────────┼──────────────────────────────────┤
│ MVP, 1 dev │ Monolith + VPS + Docker Compose │
├────────────────┼──────────────────────────────────┤
│ Startup, 2–5 │ Modular monolith + managed PG │
├────────────────┼──────────────────────────────────┤
│ Growing, 5–15 │ Monolith + horizontal scaling │
│ │ + read replica + Redis cache │
├────────────────┼──────────────────────────────────┤
│ Scale-up 15+ │ Extract 1–2 "hot" services │
│ │ keep the rest as monolith (not all at once!) │
├────────────────┼──────────────────────────────────┤
│ Enterprise │ Full microservices + k8s │
├────────────────┼──────────────────────────────────┤
│ SaaS b2b │ Multi-tenancy + strict CI/CD │
├────────────────┼──────────────────────────────────┤
│ E-commerce │ Shopify or monolith + Redis cart │
├────────────────┼──────────────────────────────────┤
│ High writes │ Queues + event-driven │
├────────────────┼──────────────────────────────────┤
│ High reads │ CDN + Redis cache + read replicas│
├────────────────┼──────────────────────────────────┤
│ Realtime │ WebSockets (Reverb/Soketi) │
├────────────────┼──────────────────────────────────┤
│ Global CDN │ Cloudflare R2 + Workers │
├────────────────┼──────────────────────────────────┤
│ AI features │ FastAPI sidecar + OpenAI API │
└────────────────┴──────────────────────────────────┘

GOLDEN RULE: start with a monolith.
Migrate to microservices only when a SPECIFIC part
becomes a bottleneck — not "just in case" upfront.
```

---

## BLOCK 12 — SELECTION MATRIX (updated)

```
Beginner + no budget + need a website:
 → WordPress + Astra + free Hostinger hosting

Beginner + no budget + need mobile:
 → Flutter + Firebase + Railway (free)

Intermediate + iOS + startup:
 → SwiftUI + Laravel + Hetzner VPS + Supabase or MinIO

Experienced + iOS + team:
 → Full stack from this guide (files 01–20)

No Mac + need iOS+Android:
 → React Native + Expo + Firebase / Supabase

E-commerce fast:
 → Shopify (no code) or WordPress + WooCommerce

SaaS / Dashboard:
 → Next.js + Supabase + Vercel (free start)

High load:
 → Go backend + PostgreSQL + Redis + AWS / Hetzner

Telegram-first:
 → aiogram + FastAPI + Railway
```
