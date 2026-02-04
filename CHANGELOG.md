# Shipshape Changelog

A macOS menubar app for monitoring Netlify and Vercel deployments.
*Keep your deploys shipshape.*

---

## Current State

> **Last Updated:** 2026-02-04
> **Status:** Development (functional, not released)
> **Domain:** shipshape.it ("Ship it!")

### What's Working

- [x] Menubar icon with color-coded status (green/yellow/red/gray)
- [x] Vercel API integration (projects, deployments)
- [x] Netlify API integration (sites, deploys)
- [x] Active section showing building/recent deployments (last hour)
- [x] Projects sorted chronologically (most recent first)
- [x] Click deployment → opens dashboard (Vercel/Netlify admin)
- [x] Context menu → "Open Live Site", "Copy URL"
- [x] Skipped build detection (monorepo deploys with no changes)
- [x] 7-day error recency window (old errors don't make menubar red)
- [x] **Turbo polling** (10s during builds, 30s recent, 5min idle)
- [x] Build duration display inline with timestamp
- [x] System notifications for build events
- [x] Secure token storage in Keychain

### What's Next

- [ ] App icon (ship with colored flag)
- [ ] Register useshipshape.com domain
- [ ] Landing page
- [ ] Product Hunt launch
- [ ] Real-time via Vercel streaming events API (v1.2)

### Quick Verification

```bash
# Build from command line
cd DeployStatus && xcodebuild -scheme DeployStatus -configuration Debug build

# Run
open ~/Library/Developer/Xcode/DerivedData/DeployStatus-*/Build/Products/Debug/DeployStatus.app
```

---

## History

Format: `[DESCRIPTION] — [FILES] ([CONTEXT])`

---

## 2026-02-04 - Rebrand to Shipshape & Turbo Polling

### Direction & Vision
- Renamed from "DeployStatus" to **Shipshape** — "Keep your deploys shipshape"
- Implemented turbo polling for near real-time updates during builds
- Added build duration display (like Shiplog competitor)
- Created comprehensive marketing plan

### Changes

- **Renamed app to Shipshape** — `ShipshapeApp.swift`, `MenuContentView.swift`, `Constants.swift`
  - Updated all UI text references
  - Changed keychain/UserDefaults keys to `shipshape.*`

- **Turbo polling during builds** — `Constants.swift`
  - Active interval: 30s → **10s** (3x faster during builds)
  - Recent interval: 60s → 30s
  - Recent duration: 2min → 3min (stay alert longer after changes)

- **Build duration display** — `DeploymentRowView.swift`
  - Shows "41s · 2m ago" format inline
  - Uses monospaced digits for alignment
  - Only shows for completed builds

- **Created marketing plan** — `MARKETING.md`
  - Domain strategy (useshipshape.com)
  - Product Hunt launch checklist
  - Competitive positioning
  - Roadmap through v2.0

### Insights

- **Vercel streaming API** exists (`/v3/deployments/{id}/events?follow=1`) for true real-time logs, but requires persistent connection
- **APNs for macOS** now works with Developer ID distribution (not just App Store)
- **Zeitgeist pattern**: Webhooks → Backend → APNs → App for true real-time

### Technical Notes

- Turbo polling (10s) during builds catches status changes quickly without needing webhooks
- Build duration calculated from `readyAt - createdAt`
- Keychain migration: old tokens under `deploystatus.*` won't carry over (users re-add accounts)

### Pending

- [ ] Register useshipshape.com
- [ ] Design app icon (ship with flag)
- [ ] Vercel streaming events integration for even faster updates

---

## 2026-02-04 - Skipped Build Detection & Error Recency

### Direction & Vision
- Menubar indicator should reflect *actionable* state, not historical errors
- Skipped monorepo builds (no changes) should show gray, not red
- Old errors from abandoned projects shouldn't permanently affect status

### Changes

- **Added `.skipped` status to DeploymentStatus enum** — `Models/Deployment.swift` (display name, gray color, forward.fill icon)

- **Fixed Netlify skipped build detection** — `Services/API/NetlifyService.swift`
  - Updated `parseStatus` to accept `deployTime` parameter
  - If state="error" but no error message AND no deploy time → `.skipped`
  - Added keywords: "skipped", "canceled", "no changes", "ignored", "not in scope"

- **Fixed Vercel skipped build detection** — `Services/API/VercelService.swift`
  - Added `errorCode`, `errorMessage`, `buildingAt` fields to VercelDeployment
  - Updated `parseStatus` to detect skipped builds with same heuristics
  - If state="ERROR" but no error message AND never started building → `.skipped`

- **Added 7-day error recency window** — `Store/DeploymentStore.swift`
  - `overallStatus` only considers errors from projects active in last 7 days
  - Old errors from abandoned projects no longer make menubar permanently red

- **Added `.skipped` to PollingManager switch** — `Services/PollingManager.swift` (exhaustive switch fix)

### Insights

- **Netlify monorepo behavior**: Returns `state="error"` with `error_message=nil` for skipped builds. Real errors always have error messages.
- **Vercel monorepo behavior**: Returns `state="ERROR"` with no `errorMessage` and no `buildingAt` timestamp for skipped builds.
- **Recency matters**: `sopra-eggs-landing` had a real npm build error from Jan 27th — legitimate but irrelevant for daily status.

### Technical Notes

- Netlify `deploy_time` field: `nil` or `0` for skipped builds, non-zero for actual builds
- Vercel `buildingAt` field: `nil` for skipped builds (build never started)
- Both services now pass additional context to `parseStatus` for better classification

### Pending

- [ ] Consider making 7-day window configurable in settings

---

## 2026-02-04 - Click Behavior & UI Polish

### Direction & Vision
- Default click should open dashboard (where you take action), not live site
- Context menu provides alternative actions

### Changes

- **Changed deployment click to open dashboard** — `Views/Menu/DeploymentRowView.swift`
  - `onTapGesture` now calls `openDashboard()` (adminUrl)
  - Renamed `openDeployment()` to `openDashboard()` for clarity

- **Reorganized context menu** — `Views/Menu/DeploymentRowView.swift`
  - "Open in Dashboard" as primary action
  - "Open Live Site" and "Copy Site URL" for deployment URL access
  - "View Build Logs" option for error states

### Insights

- Users checking deployments usually want to take action (view logs, retry, check settings) rather than view the live site
- Live site access is secondary — available via context menu

---

## 2026-02-04 - Active Section & Chronological Sorting

### Direction & Vision
- Show what matters NOW at the top (building + recently deployed)
- Don't make users think about which service (Vercel vs Netlify)
- Sort by activity, not alphabetically

### Changes

- **Added Active section** — `Views/Menu/ActiveSectionView.swift`
  - Shows projects currently building OR with activity in last hour
  - Combines both Vercel and Netlify projects
  - Building/queued projects sorted first, then by recency

- **Added activeProjects computed property** — `Store/DeploymentStore.swift`
  - Filters projects with `building`, `queued`, or recent activity
  - Sorts building first, then by `latestDeployment.createdAt`

- **Changed project sorting to chronological** — `Store/DeploymentStore.swift`
  - Projects now sorted by `latestDeployment.createdAt` descending
  - Most recently deployed project appears first

- **Sorted deployments by date** — `Store/DeploymentStore.swift`
  - `fetchedProjects[index].deployments.sorted { $0.createdAt > $1.createdAt }`
  - Ensures `latestDeployment` is always the newest

### Insights

- 1-hour window for "recent" activity provides good balance — shows relevant projects without clutter
- Service icons inline with project name in Active section helps identify source at a glance

---

## 2026-02-03 - Initial Implementation

### Direction & Vision
- macOS menubar app for monitoring Netlify + Vercel deployments
- Minimal UI, maximum utility — see status at a glance
- No Dock icon (LSUIElement), lives in menubar only

### Changes

- **Created Xcode project** — `DeployStatus.xcodeproj`
- **App entry point** — `DeployStatusApp.swift` (MenuBarExtra, WindowGroup for settings)
- **Core models** — `Models/` (Account, Project, Deployment, DeploymentStatus, Service)
- **API services** — `Services/API/` (VercelService, NetlifyService as Swift actors)
- **State management** — `Store/DeploymentStore.swift` (@Observable, central state)
- **Polling** — `Services/PollingManager.swift` (smart intervals based on activity)
- **Keychain** — `Services/KeychainHelper.swift` (secure token storage)
- **Notifications** — `Services/NotificationManager.swift` (build started/succeeded/failed)
- **Menu views** — `Views/Menu/` (MainMenuView, ProjectSectionView, DeploymentRowView, StatusIndicator)
- **Settings views** — `Views/Settings/` (AccountsSettingsView, NotificationsSettingsView)
- **Constants** — `Helpers/Constants.swift` (API URLs, polling intervals, keychain keys)
- **Date extension** — `Helpers/DateExtensions.swift` (relative time formatting)
- **JSON decoder extension** — `Helpers/JSONDecoderExtensions.swift` (flexible ISO8601 parsing)

### Technical Notes

- Swift actors for API services ensure thread safety
- @Observable (Swift Observation framework) for reactive state
- URLSession for networking (no third-party dependencies)
- Keychain Services API for secure token storage
- UNUserNotificationCenter for system notifications

### Architecture Decisions

- **Actor-based services**: Prevents data races in concurrent API calls
- **Central store pattern**: Single source of truth, easy to reason about
- **Polling over WebSockets**: Simpler, works with both Vercel and Netlify APIs
- **MenuBarExtra**: Native SwiftUI menubar integration (macOS 13+)

---

## Bootstrap Notes

> This changelog was bootstrapped on 2026-02-04 from session history.
> Earlier entries reconstructed from code review and git history.
