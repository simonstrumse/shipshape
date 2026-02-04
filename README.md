# Shipshape

**Keep your deploys shipshape.**

A native macOS menubar app for monitoring Netlify and Vercel deployments in real-time.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Why Shipshape?

| Feature | Shipshape | Electron Apps |
|---------|-----------|---------------|
| **Size** | ~2MB | 90MB+ |
| **Memory** | ~20MB | 300MB+ |
| **Monorepo Support** | Skipped = gray (not red) | False error alerts |
| **Polling** | 10s during builds | 30-60s typical |
| **Native** | SwiftUI, macOS Keychain | Web wrapper |

## Features

- **Unified Dashboard** — See all active builds across Vercel and Netlify in one place
- **Turbo Polling** — 10-second refresh during active builds for near real-time updates
- **Monorepo-Aware** — Correctly shows skipped builds as gray, not false-positive errors
- **Smart Notifications** — Desktop alerts when builds complete or fail
- **Secure Storage** — API tokens stored in macOS Keychain
- **Lightweight** — Native SwiftUI, ~2MB on disk

## Installation

### Download

[**Download Shipshape-1.0.0.dmg**](https://github.com/simonstrumse/shipshape/releases/latest)

1. Open the DMG
2. Drag Shipshape to Applications
3. Launch from Spotlight or Applications folder

### Requirements

- macOS 14.0 (Sonoma) or later
- Universal binary (Apple Silicon + Intel)

## Setup

### 1. Get Your API Tokens

**Vercel:**
1. Go to [Vercel Settings → Tokens](https://vercel.com/account/tokens)
2. Create a new token with "Full Account" scope
3. Copy the token

**Netlify:**
1. Go to [User Settings → Applications](https://app.netlify.com/user/applications)
2. Under "Personal access tokens", click "New access token"
3. Copy the token

### 2. Add Accounts in Shipshape

1. Click the Shipshape icon in your menubar
2. Open **Settings**
3. Go to the **Accounts** tab
4. Click **Add Account**
5. Select Vercel or Netlify, paste your token

Your projects will load automatically.

## How It Works

### Status Colors

| Color | Meaning |
|-------|---------|
| Green | All recent builds succeeded |
| Yellow | Build in progress |
| Red | Recent build failed |
| Gray | Idle (no recent activity) |

### Menubar Indicator

The menubar icon reflects the **worst status** of your active projects:
- Only projects with recent activity (last hour) affect the indicator
- Skipped monorepo builds don't trigger false alerts

### Polling Intervals

| Scenario | Interval |
|----------|----------|
| Active build | 10 seconds |
| Recent activity (< 1 hour) | 30 seconds |
| Idle | 5 minutes |

## Building from Source

```bash
git clone https://github.com/simonstrumse/shipshape.git
cd shipshape
xcodebuild -scheme DeployStatus -configuration Release build
```

The built app will be in `build/Build/Products/Release/`.

## Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI + AppKit (NSStatusItem)
- **State Management:** @Observable (Swift Observation)
- **Concurrency:** Swift actors for thread-safe API calls
- **Storage:** macOS Keychain (tokens), UserDefaults (settings)

## Contributing

Contributions are welcome! Please open an issue first to discuss major changes.

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Made with SwiftUI**
