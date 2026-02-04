# Social Media Launch Drafts

## Twitter/X

### Main Launch Tweet

```
Shipped: Shipshape - a native macOS menubar app for Vercel + Netlify deployment monitoring.

- 2MB app size (vs 90MB+ Electron)
- 10s polling during active builds
- Monorepo-aware (skipped builds = gray, not red)
- Tokens stored in macOS Keychain

Free & open source.

[GIF attachment: product-demo.gif]

https://github.com/simonstrumse/shipshape
```

### Thread Follow-up (optional)

```
Why I built this:

I got tired of refreshing Vercel/Netlify dashboards during deploys.

Existing tools were either:
- Electron apps eating 300MB RAM
- Showing false errors for skipped monorepo builds
- Polling too slowly during active builds

So I built a native SwiftUI app that just works.
```

---

## Reddit

### r/webdev

**Title:** I built a native macOS menubar app for monitoring Vercel and Netlify deployments

**Body:**
```
Hey r/webdev!

I just released Shipshape, a free menubar app for macOS that monitors your Vercel and Netlify deployments.

**Why I built it:**
I got tired of constantly checking dashboards during deploys, and existing tools were either Electron-based (300MB+ RAM) or didn't handle monorepo builds correctly.

**Key features:**
- Native SwiftUI (~2MB app, ~20MB RAM)
- 10-second polling during active builds
- Monorepo-aware: skipped builds show gray, not false-positive red
- Unified view of both Vercel and Netlify
- API tokens stored securely in macOS Keychain

It's free and open source: https://github.com/simonstrumse/shipshape

Would love feedback from anyone who deploys to Vercel or Netlify regularly!
```

### r/nextjs

**Title:** Made a native menubar app for monitoring Vercel deployments (macOS)

**Body:**
```
Built a lightweight macOS menubar app called Shipshape that shows your Vercel deployment status at a glance.

- Polls every 10 seconds during active builds
- Desktop notifications when builds complete or fail
- Handles monorepo setups correctly (skipped = gray, not error)
- Native SwiftUI, not Electron (~2MB vs 90MB+)

Also supports Netlify if you use both services.

Free & open source: https://github.com/simonstrumse/shipshape

[GIF showing the app in action]
```

### r/sveltejs

**Title:** Native macOS menubar app for Vercel/Netlify deployment monitoring

**Body:**
```
If you deploy SvelteKit to Vercel or Netlify, you might find this useful.

I built Shipshape - a lightweight menubar app that shows deployment status and sends notifications when builds complete.

Key features:
- 10s polling during active builds
- Monorepo support (skipped builds don't show as errors)
- Native macOS app (~2MB, not Electron)
- Secure token storage in Keychain

Free and open source: https://github.com/simonstrumse/shipshape
```

---

## Product Hunt (Ship page draft)

**Tagline:** Keep your deploys shipshape

**Description:**
```
Shipshape is a native macOS menubar app that monitors your Vercel and Netlify deployments in real-time.

Built for developers who ship frequently and want instant visibility into their deployment status without keeping dashboards open.

Key features:
- Turbo polling (10s) during active builds
- Desktop notifications on build completion
- Monorepo-aware status indicators
- Native SwiftUI (~2MB app size)
- Secure macOS Keychain storage

Free and open source.
```

---

## Hacker News

**Title:** Show HN: Shipshape – Native macOS menubar app for Vercel/Netlify monitoring

**Body:**
```
I built a native menubar app for monitoring Vercel and Netlify deployments.

Why: I got tired of checking dashboards during deploys. Existing solutions were Electron apps (300MB+ RAM) or didn't handle monorepo skipped builds correctly.

Tech: SwiftUI, ~2MB on disk, ~20MB RAM, tokens stored in macOS Keychain.

Features:
- 10s polling during active builds, 5min when idle
- Desktop notifications on completion/failure
- Shows Vercel + Netlify in unified view
- Skipped monorepo builds show gray (not false-positive red)

Free and open source: https://github.com/simonstrumse/shipshape

Would appreciate feedback, especially around what other deployment platforms to support.
```
