# 10 — Figma MCP — Design to Code from Day One

## What is Figma MCP

Figma MCP (Model Context Protocol) allows Claude Code to read Figma designs directly and generate SwiftUI code from mockups. Just provide a link to a frame in Figma.

---

## Installation (One Time)

### 1. Add MCP Server to Claude Code

Open `~/.claude/claude_desktop_config.json` (or via `Claude Code` → Settings → MCP Servers):

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-figma"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "figd_xxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 2. Get a Figma Access Token

1. Figma → account → **Settings** → **Personal access tokens**
2. Generate new token → copy it

### 3. Verify It Works

In Claude Code, type:
```
Read this Figma frame: https://www.figma.com/design/XXXX/...
```

---

## Starter Prompt — Give a Link and Go

Copy this prompt at the beginning of every new project. Just substitute your Figma link.

```
Here is the app design: https://www.figma.com/design/XXXX/...

Analyze all screens and do the following:

1. **Screen List** — list all screens you see, grouped by section (Auth, Feed, Detail, Profile, etc.)

2. **Functionality** — for each screen, describe what it does and what actions are available to the user

3. **Stack** — propose a technical stack:
   - iOS: SwiftUI, minimum iOS version, required frameworks (MapKit, PhotosUI, etc.)
   - Backend: language/framework, DB, queues, search, file storage
   - Infrastructure: Docker, services

4. **Project Structure** — propose folders and files for iOS (Features, Core, DesignSystem)

5. **Design Tokens** — extract colors, fonts, spacing and create:
   - Colors.swift
   - Typography.swift
   - Spacing/Radius constants

6. **Development Plan** — break into phases (Sprint 1, 2, 3...) with priorities:
   - What to do first (Auth, basic CRUD)
   - What can be deferred (push, analytics)

7. **Risks** — highlight complex areas that will require special attention

8. **Documentation** — compile a list of official documentation to study before development:
   - Apple Developer docs (specific pages, not just sections)
   - Laravel/PHP docs
   - Third-party libraries that will be needed
   - For each — one line explaining why it's needed in this project

Stack preferences:
- iOS: SwiftUI + MVVM, iOS 16+, xcodegen, SwiftLint
- Backend: Laravel 11 + PostgreSQL + Redis + Meilisearch
- Infra: Docker Compose
- Interface language: follows phone language (Localizable.strings)
- Architecture: Clean Architecture — DI via protocols, layers View→ViewModel→UseCase→APIClient, AppError enum for errors, OSLog for logging, one ViewModel per screen, Features don't know about each other
```

After this, Claude will read all frames via Figma MCP and produce a complete plan. Then you can say "start with the Auth screen" or "create project.yml".

---

## How to Use When Starting a New Project

### Step 1 — Provide the Design Link

```
Here is the app design link: https://www.figma.com/design/ABC123/MyApp?node-id=1-2
Help plan the SwiftUI project structure based on these mockups.
```

Claude will automatically:
- Read all screens and components
- Suggest a folder structure
- Identify the color palette and typography
- Generate `Colors.swift`, `Typography.swift`

### Step 2 — Generate Screens

```
Generate SwiftUI code for the Home screen from this frame: [node-id]
Stack: SwiftUI, MVVM, iOS 16+
```

### Step 3 — Design Tokens

```
Extract all colors and fonts from the file https://www.figma.com/design/XXX/...
and create Colors.swift and Typography.swift
```

---

## Development Workflow

```
1. Designer updated the mockup
   ↓
2. You give a link to the specific frame to Claude Code
   ↓
3. Claude reads the mockup via Figma MCP
   ↓
4. Generates a SwiftUI component
   ↓
5. You adapt it to the existing project components
```

---

## Useful Queries

```
# Analyze the entire design
"Analyze the design at https://figma.com/... and list all screens and components"

# Specific screen
"Generate ListingDetailView from this frame: [URL with node-id]"

# Colors
"Extract all colors from Figma and create extension Color+DH.swift"

# Component
"Generate a custom DHButton based on the component from Figma: [node-id]"

# Compare with code
"Compare the current ListingCard.swift with the mockup [URL] — what's different?"
```

---

## Extracting node-id from URL

```
https://www.figma.com/design/AbCdEfGh/MyApp?node-id=12-345

fileKey  = AbCdEfGh
node-id  = 12-345  →  passed to MCP as  12:345  (dash → colon)
```

---

## What MCP Can Do

| Capability | Description |
|---|---|
| `get_design_context` | Reads a component/frame and generates code |
| `get_screenshot` | Screenshot of a frame for visual analysis |
| `get_variable_defs` | Extracts Design Tokens (colors, sizes) |
| `search_design_system` | Searches components by name |
| `generate_diagram` | Creates a diagram in FigJam |

---

## Important — MCP Generates React/Tailwind

Figma MCP generates **React + Tailwind** code by default.  
When working on an iOS project, explicitly specify:

```
Generate SwiftUI code (not React).
Stack: SwiftUI, iOS 16+, MVVM.
Use our components: DHButton, DHTextField, ListingCard.
Colors: Color.dhPrimary, Color.dhSurface, Color.dhTextPrimary.
```

---

## Code Connect (Advanced)

Allows linking Figma components to real project components:

```
Show me the mapping of Figma components to SwiftUI: get_code_connect_map
```

Once configured — Claude will automatically use your existing components instead of generating from scratch.
