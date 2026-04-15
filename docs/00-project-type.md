# 00 — Defining the Project Type from the Design

Before planning the stack and architecture — define the project type.
Different types require different solutions.

---

## Prompt #1 — Ask 4 questions, then request the design

Insert this prompt first. Claude will ask exactly 4 questions with answer options,
then after your replies it will ask for a Figma link or idea description.

```
I want to build a product and I'm working with you.
Ask me 4 short questions with answer options — one at a time.
After my answers, ask for the design or description yourself and create a complete plan.
```

---

### Question 1 — Level

```
Question 1 of 4.

What is your level in development?

A) Beginner — never developed anything, want to learn
B) Junior — watched tutorials, tried things, but no projects yet
C) Mid-level — have 1-2 completed projects
D) Experienced — have commercial experience

[waiting for answer]
```

---

### Question 2 — Platform

```
Question 2 of 4.

What do you want to build?

A) iOS app (iPhone)
B) Android app
C) iOS + Android at once (cross-platform)
D) Website / landing page (no code — WordPress, Tilda)
E) Web application (runs in browser, requires code)
F) SaaS — subscription service for business
G) Telegram bot / mini app
H) Not sure — help me decide

[waiting for answer]
```

---

### Question 3 — Product Type

```
Question 3 of 4.

What type does your product belong to?

A) Marketplace / classifieds (like OLX, Avito, Airbnb)
B) Online store / e-commerce (catalog, cart, payment)
C) Social network (feed, follows, likes, stories)
D) Booking service (doctors, beauty, tutors, scheduling)
E) Delivery / logistics (orders, couriers, tracking)
F) SaaS / dashboard (data management, analytics)
G) ERP / CRM (business processes, employee roles)
H) EdTech (courses, lessons, tests, progress)
I) FinTech (payments, accounts, wallet, banking)
J) Healthcare (doctors, medical records, telemedicine)
K) Utility / tool (tracker, calculator, notes)
L) Not sure — I'll describe the idea, you decide

[waiting for answer]
```

---

### Question 4 — Context

```
Question 4 of 4 — the last one.

A) Goal:
 1) Learning / portfolio / personal project
 2) Startup — want to launch a product
 3) Order for a client
 4) Internal tool for a company

B) Budget for services (hosting, API, Apple Dev account):
 1) Zero — free services only
 2) Small — up to $50/month
 3) Moderate — $50-200/month
 4) No limits

C) Deadline:
 1) None, working at my own pace
 2) Need an MVP fast (1-4 weeks)
 3) 1-3 months
 4) 3-6 months

Answer in the format: A2, B1, C3

[waiting for answer]
```

---

### After 4 questions — Claude requests the design itself

```
After receiving answers to all 4 questions — say:

"Great! Now:
- If you have a design in Figma — share the link
- If there's no design — describe the idea in your own words (2-5 sentences)
- If you have both — share both"
```

---

## Prompt #2 — After answers, you provide Figma or description

If you have Figma:
```
Here is the design link: https://www.figma.com/design/XXXX/...

Now considering everything I told you — analyze the layout and create a plan.
```

If no Figma — describe the idea in words:
```
I don't have a design, but here's the idea: [describe in your own words what the app should do]

Considering my answers — create a development plan.
```

---

## What Claude does after the answers

Based on the answers and design/description, Claude builds a plan with this structure:

```
═══════════════════════════════════════════
 DEVELOPER PROFILE
═══════════════════════════════════════════
Level: [Beginner / Mid-level / Experienced]
Role: [Solo / Team]
Mode: [Writing myself / With explanations / Claude writes]

→ This determines: depth of explanations, stack complexity,
 number of abstractions, strictness of architecture

═══════════════════════════════════════════
 PROJECT TYPE
═══════════════════════════════════════════
Type: [Marketplace / E-commerce / SaaS / ...]
Platform: [iOS / Android / iOS+Android / Web / SaaS]
Audience: [B2C / B2B / Marketplace / Internal]
Goal: [Portfolio / Startup / Client / Internal]

═══════════════════════════════════════════
 STACK — chosen for your type and level
═══════════════════════════════════════════
iOS/Frontend: [...]
Backend: [...] or [Firebase/Supabase if no experience]
DB: [...]
Infra: [...]
NOT needed: [...] ← remove unnecessary parts

═══════════════════════════════════════════
 CONSTRAINTS — accounted for
═══════════════════════════════════════════
Budget: [free only / up to $50 / no limit]
Deadline: [MVP in N weeks]
Platform: [Mac / Windows — warning]
Apple Dev: [requires $99/year / not required]

═══════════════════════════════════════════
 SCREENS AND FEATURES
═══════════════════════════════════════════
[Screen groups with description of each feature]

═══════════════════════════════════════════
 DOCUMENTATION TO STUDY
═══════════════════════════════════════════
[Specific docs pages + one line why each matters]

═══════════════════════════════════════════
 SPRINT PLAN
═══════════════════════════════════════════
Sprint 1 (week 1-2): Foundation
 - auth, navigation, design system, .gitignore, .env
Sprint 2 (week 3-5): Core feature
 - main functionality from the design
Sprint 3 (week 6-8): Secondary functionality
Sprint 4 (week 9-10): Polish, tests, App Store

[For beginners — breakdown by days, not sprints]
[If hard deadline — what to cut from MVP]

═══════════════════════════════════════════
 RISKS
═══════════════════════════════════════════
[Technical challenges, pitfalls of the project type]

ADAPTATION RULES:
- Beginner (A/B in question 1):
 → Explain each step
 → Suggest Firebase/Supabase instead of own server
 → No DI and protocols at start — add later
 → Highlight "do now" vs "can do later"

- Experienced (C/D in question 1):
 → Minimal explanations, maximum code
 → Full architecture from day one
 → DI, protocols, tests — mandatory

- No budget (A in question 11):
 → Supabase (DB + Auth + Storage) — free up to 500MB
 → Firebase (push, analytics) — free tier
 → Railway / Render — free hosting
 → No Twilio — Firebase SMS or Email OTP

- Windows / no Mac (B in question 12):
 → Native iOS is impossible without a Mac
 → Alternative: React Native + Expo (works on Windows)
 → Or: rent a Mac in the cloud (MacStadium, MacinCloud)

- No deadline (A in question 10):
 → Do it right from scratch
 → Full tests, clean architecture

- Hard deadline (B in question 10):
 → MVP: core feature only, everything else — v2
 → Technical debt — explicitly record what was deferred and why
```

---

## How Claude adapts the plan

After answering the questions, Claude changes the recommendations:

| Situation | What changes |
|---|---|
| Beginner | Simpler stack, step-by-step explanations, fewer abstractions |
| No backend experience | Suggest Supabase/Firebase instead of own server |
| No budget | Free tiers only: Supabase free, Firebase free, Railway free |
| Solo developer | Monolithic backend is fine, fewer microservices |
| No deadline | Can do it right from scratch, no cutting corners |
| Hard deadline | MVP first, technical debt later — but record what was deferred |
| No iPhone | Warn that push/background geolocation only works on device |
| No Apple Developer | Can't publish to App Store, TestFlight only for own devices |

---

## Stack by Platform

### D — No-code website (WordPress / Tilda / Webflow)

```
When to choose:
- Landing page, business card, blog, portfolio
- Online store without complex logic
- Client wants to edit content themselves
- No development budget

WordPress stack:
 CMS: WordPress (https://wordpress.org/documentation/)
 Hosting: SpinupWP, Kinsta, or VPS (Hetzner €4/month)
 Theme: Astra / GeneratePress (or custom on ACF)
 Plugins: ACF Pro (fields), WooCommerce (shop),
 Yoast SEO, WP Rocket (cache)
 Deploy: Git + WP Pusher, or just FTP

Documentation:
 https://developer.wordpress.org/ ← main dev portal
 https://developer.wordpress.org/themes/ ← theme development
 https://developer.wordpress.org/plugins/ ← plugin development
 https://www.advancedcustomfields.com/resources/← ACF — custom fields
 https://woocommerce.com/documentation/ ← WooCommerce shop

Tilda stack (completely no-code):
 https://help.tilda.cc/ ← Tilda documentation
 Suitable for: landing pages, events, portfolios

Webflow (visual development + code):
 https://university.webflow.com/ ← Webflow University
 Suitable for: complex landing pages, CMS sites
```

---

### A — iOS app (Swift / SwiftUI)

→ This entire guide (files 01-20) is about exactly this

```
Apple Documentation:
 https://developer.apple.com/documentation/swiftui ← SwiftUI
 https://developer.apple.com/documentation/swift ← Swift language
 https://developer.apple.com/tutorials/swiftui ← Apple tutorials
 https://developer.apple.com/design/human-interface-guidelines/ ← HIG
 https://developer.apple.com/app-store/review/guidelines/ ← App Store rules

Stack: SwiftUI + MVVM + Laravel backend (see files 01-15)
```

---

### B — Android app (Kotlin / Jetpack Compose)

```
Stack:
 Language: Kotlin
 UI: Jetpack Compose (Android equivalent of SwiftUI)
 IDE: Android Studio
 Architecture: MVVM + Repository pattern
 DI: Hilt (Dagger)
 Network: Retrofit + OkHttp
 Local DB: Room
 Navigation: Navigation Compose
 Backend: Laravel / Node.js (same as for iOS)

Documentation:
 https://developer.android.com/jetpack/compose ← Jetpack Compose
 https://developer.android.com/kotlin ← Kotlin for Android
 https://developer.android.com/topic/architecture ← architecture (MVVM)
 https://developer.android.com/training/dependency-injection/hilt-android ← Hilt DI
 https://square.github.io/retrofit/ ← Retrofit networking
 https://developer.android.com/google/play/billing ← Google Play Billing
 https://developer.android.com/distribute/console ← Play Console

iOS → Android equivalents:
 SwiftUI → Jetpack Compose
 Xcode → Android Studio
 TestFlight → Google Play Internal Testing
 Apple Pay → Google Pay
 APNs → FCM (Firebase Cloud Messaging)
 Keychain → Android Keystore + EncryptedSharedPreferences
 UserNotifications → NotificationManager / WorkManager
```

---

### C — iOS + Android (React Native / Flutter)

```
React Native (JavaScript/TypeScript):
 IDE: VS Code — works on Windows/Mac/Linux 
 Language: TypeScript
 UI: React Native components
 Navigation: React Navigation
 State: Zustand / Redux Toolkit
 Network: Axios / React Query
 Push: Firebase Cloud Messaging (FCM)

 Documentation:
 https://reactnative.dev/docs/getting-started ← React Native docs
 https://reactnavigation.org/docs/getting-started ← navigation
 https://expo.dev/ ← Expo (easier start)
 https://docs.expo.dev/ ← Expo docs

Flutter (Dart):
 IDE: VS Code / Android Studio — Windows/Mac/Linux 
 Language: Dart
 UI: Flutter widgets
 Architecture: BLoC / Riverpod
 Network: Dio / http

 Documentation:
 https://docs.flutter.dev/ ← Flutter docs
 https://dart.dev/guides ← Dart language
 https://pub.dev/ ← packages (pub.dev)
 https://bloclibrary.dev/ ← BLoC pattern

When React Native:
 - You already know JavaScript/TypeScript
 - No Mac (can develop on Windows via Expo)
 - Team of web developers

When Flutter:
 - Maximum performance needed
 - Unified UI on iOS + Android + Web + Desktop
 - Team ready to learn Dart
```

---

### E — Web application (Full-stack)

```
If you chose E-commerce / SaaS / Dashboard in question 3:

Next.js stack (recommended):
 Frontend: Next.js 14+ (React) + TypeScript
 Styling: Tailwind CSS
 UI lib: shadcn/ui
 Backend: Next.js API Routes / Laravel
 DB: PostgreSQL (Supabase free tier)
 Auth: NextAuth.js / Supabase Auth
 Deploy: Vercel (free for start)

 Documentation:
 https://nextjs.org/docs ← Next.js
 https://tailwindcss.com/docs ← Tailwind
 https://ui.shadcn.com/docs ← shadcn/ui
 https://supabase.com/docs ← Supabase
 https://next-auth.js.org/getting-started ← NextAuth

Laravel + Blade (if you already know PHP):
 Frontend: Blade templates + Alpine.js / Livewire
 Backend: Laravel 11
 DB: PostgreSQL
 Deploy: Forge + Hetzner / Railway

 Documentation:
 https://laravel.com/docs ← Laravel
 https://livewire.laravel.com/docs ← Livewire
 https://alpinejs.dev/ ← Alpine.js
```

---

### G — Telegram Mini App / Bot

```
Stack:
 Bot: python-telegram-bot / Grammy (Node.js)
 Mini App: React / Vue + Telegram Web App API
 Backend: FastAPI (Python) / Express (Node)
 DB: PostgreSQL / SQLite for simple bots
 Hosting: Railway / Render (free)

Documentation:
 https://core.telegram.org/bots/api ← Bot API
 https://core.telegram.org/bots/webapps ← Mini Apps
 https://docs.python-telegram-bot.org/ ← python-telegram-bot
 https://grammy.dev/ ← Grammy (Node.js)
```

---

## Stack by Project Type

### Marketplace / Classifieds
*(Avito, OLX, Craigslist)*

```
iOS: MapKit, PhotosUI, CoreLocation, UserNotifications
Backend: PostgreSQL + PostGIS (geo search), Meilisearch (search), Redis, S3/MinIO
Extra: WebSockets (chat), Push (new messages)
Not needed: complex cart, StoreKit subscriptions (if no monetization)
```

Key decisions:
- Geolocation via PostGIS `ST_DWithin`
- Photos via Spatie MediaLibrary
- Chat via Laravel Reverb + WebSocket

---

### E-commerce
*(shop, catalog, cart, payment)*

```
iOS: StoreKit 2 (if in-app), PhotosUI
Backend: PostgreSQL, Redis (cart, sessions), Stripe/LiqPay
Extra: Queues (order processing), Email (receipts)
Not needed: PostGIS, Meilisearch (if catalog is small — simple LIKE)
```

Key decisions:
- Cart in Redis or locally (UserDefaults before login)
- Payment: Stripe SDK for iOS + webhook on backend
- Inventory: DB transactions to prevent oversell

---

### SaaS / Dashboard
*(management, subscription, analytics)*

```
iOS: Charts (iOS 16+), PDFKit (export)
Backend: PostgreSQL, Redis, queues for heavy reports
Extra: Multi-tenancy (companies/teams), user roles
Not needed: PostGIS, MediaLibrary (if no file uploads)
```

Key decisions:
- Roles via Spatie Permission (`composer require spatie/laravel-permission`)
- Multi-tenancy: separate DB schema or `tenant_id` on every table
- Subscriptions: Laravel Cashier + Stripe

---

### Social App
*(feed, follows, likes, stories)*

```
iOS: AVFoundation (video), PhotosUI, UserNotifications
Backend: PostgreSQL, Redis (counters, feed), queues
Extra: CDN for media (not MinIO — use Cloudflare/AWS), WebSockets
Not needed: PostGIS (if no geolocation)
```

Key decisions:
- Feed: fanout-on-write (on post, write to feed of each follower) — Redis
- Like/view counters: Redis INCR, then sync to DB
- Video: processing via queue (ffmpeg), storage in S3

---

### Service App
*(doctor appointments, beauty, tutors)*

```
iOS: EventKit (calendar), MapKit, UserNotifications
Backend: PostgreSQL, Redis, queues (reminders)
Extra: Cron jobs (reminders one hour before), Email/SMS
Not needed: Meilisearch (if low data volume)
```

Key decisions:
- Schedule slots: `time_slots` table with `is_booked`
- Reminders: Laravel Scheduler + queue
- Double booking: DB transaction + unique constraint

---

### ERP / CRM
*(business management, reports, roles)*

```
iOS: Charts, PDFKit, DocumentPicker
Backend: PostgreSQL, Redis, queues for reports
Extra: Roles and permissions (Spatie Permission), audit log
Not needed: Meilisearch, PostGIS
```

Key decisions:
- Change audit: `spatie/laravel-activitylog`
- Export: queue → generate → S3 → notify user
- Access control: Gate + Policy for each resource

---

### Delivery / Logistics
*(orders, courier tracking, routes)*

```
iOS: MapKit + MKDirections (routes), CoreLocation (background), UserNotifications
Backend: PostgreSQL + PostGIS, Redis (real-time positions), WebSockets
Extra: Background Location (entitlement required!)
Not needed: Meilisearch
```

Key decisions:
- Tracking: background location updates → WebSocket → client
- Route: MKDirections or Google Routes API
- Order statuses: state machine (pending → assigned → picked → delivered)

---

### EdTech
*(courses, lessons, progress, tests)*

```
iOS: AVFoundation (video lessons), AVPlayer, CoreData (offline)
Backend: PostgreSQL, S3 (video), CloudFront CDN
Extra: DRM for content protection, progress sync
Not needed: PostGIS, Meilisearch (basic search)
```

Key decisions:
- Video: HLS streaming via CloudFront, not direct S3 links
- Offline: lesson downloads + CoreData for progress
- Progress: sync on network restore

---

### FinTech
*(payments, accounts, transactions)*

```
iOS: PassKit (Apple Pay), LocalAuthentication (Face ID), CryptoKit
Backend: PostgreSQL (ACID transactions), Redis, queues
Extra: PCI DSS compliance, audit of all operations, encryption
Not needed: MediaLibrary, Meilisearch
```

Key decisions:
- Never store card data — only via Stripe/tokenization
- Double-entry bookkeeping for transactions
- Face ID: `LocalAuthentication` to confirm payments
- Log everything: who, what, when, from which IP

---

### Healthcare
*(doctors, patients, medical records, telemedicine)*

```
iOS: HealthKit, AVFoundation (video calls), CryptoKit
Backend: PostgreSQL (column encryption), S3 (encryption)
Extra: HIPAA compliance (USA), encryption at rest and in transit
Not needed: Meilisearch (search over medical data — a separate topic)
```

Key decisions:
- Medical data: Laravel Encrypted Columns or application-level encryption
- Video calls: WebRTC (Agora, Daily.co SDK) — not WebSocket
- HealthKit: request permissions for specific data types
- User consent: versioned Terms of Service

---

## Technology Matrix

| Technology | When needed |
|---|---|
| PostGIS | Geo search, "near me", routes |
| Meilisearch | Full-text search (>1000 records) |
| WebSockets/Reverb | Chat, real-time notifications, tracking |
| Redis | Cache, queues, sessions, counters |
| MinIO/S3 | User file/photo uploads |
| Stripe/Cashier | Payments, subscriptions |
| Spatie Permission | Roles and permissions (admin, manager, user) |
| HealthKit | Medical data, fitness |
| AVFoundation | Video, audio, camera |
| StoreKit 2 | In-app purchases, App Store subscriptions |
| CoreData | Offline data, disk cache |
| EventKit | iOS Calendar integration |
| PassKit | Apple Pay, Wallet |
| CryptoKit | Encryption, signatures |
