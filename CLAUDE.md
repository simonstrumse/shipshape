# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Build
cd DeployStatus && xcodebuild -scheme DeployStatus -configuration Debug build

# Run
open ~/Library/Developer/Xcode/DerivedData/DeployStatus-*/Build/Products/Debug/DeployStatus.app

# Or run directly
~/Library/Developer/Xcode/DerivedData/DeployStatus-*/Build/Products/Debug/DeployStatus.app/Contents/MacOS/DeployStatus
```

## Architecture

**Shipshape** is a native macOS menubar app (SwiftUI, macOS 13+) for monitoring Vercel and Netlify deployments.

### Core Components

```
ShipshapeApp.swift          Entry point, MenuBarExtra setup
    ↓
DeploymentStore             @Observable central state
    ├─ accounts, projects, activeProjects
    ├─ overallStatus (computed from activeProjects only)
    └─ refresh() triggers API calls
    ↓
PollingManager              Smart intervals (10s active, 30s recent, 5min idle)
    ↓
VercelService / NetlifyService    Actor-based API clients (thread-safe)
    ↓
KeychainHelper              Secure token storage
```

### Key Design Patterns

- **Actors for API services** — Thread-safe concurrent requests
- **@Observable** — Modern SwiftUI state (no Combine)
- **Turbo polling** — 10s during builds for near real-time updates
- **Active section** — Shows building + last hour activity across both services

### Status System

```swift
DeploymentStatus: queued, building, ready, error, canceled, skipped
OverallStatus: idle, ready, building, error  // Computed from activeProjects ONLY

Colors: green (ready), yellow (building), red (error), gray (idle/skipped/canceled)
```

### Monorepo Awareness

- Netlify/Vercel return `error` state for skipped monorepo builds
- Detection: `error` state + no error message + no build time = `.skipped` (gray, not red)
- Menubar indicator only reflects **activeProjects** (building or deployed in last hour)

## Key Files

| File | Purpose |
|------|---------|
| `Store/DeploymentStore.swift` | Central state, `overallStatus` logic, account management |
| `Services/PollingManager.swift` | Polling intervals, change detection, notifications |
| `Services/API/*Service.swift` | API clients with `parseStatus()` for state mapping |
| `Utilities/Constants.swift` | API URLs, polling intervals, storage keys |
| `Views/Menu/ActiveSectionView.swift` | Building + recent projects display |

## Storage Keys

Internal keys use `deploystatus.*` prefix (not `shipshape.*`) for data continuity:
- UserDefaults: `deploystatus.accounts`, `deploystatus.notificationsEnabled`, etc.
- Keychain: `com.deploystatus.tokens`

## API Limits

- Vercel: Fetches 100 projects max, displays 20 initially with "Show more"
- Netlify: Fetches all sites (default 100)
- Deployments: 5 per project (`Constants.deploymentsPerProject`)

## Changelog Skill

Use `/changelog` to read/write project history. The changelog serves as strategic memory across sessions — read before modifying unfamiliar code, write after making changes.
