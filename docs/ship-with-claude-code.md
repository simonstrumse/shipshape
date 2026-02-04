# Ship a Product with Claude Code: A Replicable Process

> **TL;DR**: This document captures the complete workflow for shipping a macOS app from concept to launch using Claude Code, including product development, visual assets, landing page, distribution, and marketing — all in a single session.

---

## Overview

**Product**: Shipshape — a native macOS menubar app for Vercel/Netlify deployment monitoring
**Time**: ~2-3 hours of prompting across sessions
**Output**: Working app, DMG installer, GitHub release, landing page, promo video, demo GIF, social media drafts

---

## Phase 1: Product Development

### 1.1 Initial Specification
Start with a clear spec. The initial prompt included:
- Target platform (macOS menubar)
- Core functionality (monitor Vercel + Netlify deployments)
- Key differentiators (native SwiftUI, monorepo-aware, turbo polling)
- Technical requirements (Keychain storage, smart polling intervals)

### 1.2 Architecture & Implementation
Claude Code created the full project structure:
```
DeployStatus/
├── App/DeployStatusApp.swift      # Entry point, MenuBarExtra
├── Models/                         # Data models (Account, Project, Deployment)
├── Services/
│   ├── API/                        # VercelService, NetlifyService (actor-based)
│   ├── PollingManager.swift        # Smart intervals (10s/30s/5min)
│   └── KeychainHelper.swift        # Secure token storage
├── Store/DeploymentStore.swift     # @Observable central state
└── Views/                          # SwiftUI views
```

### 1.3 Demo Mode for Assets
Added demo mode to show sample data without real API tokens:
```swift
var isDemoMode: Bool {
    get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.demoMode) }
    set {
        UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.demoMode)
        if newValue { loadDemoData() }
        else { /* reload real accounts */ }
    }
}
```

**Key Prompt**: "Can you add a demo mode that shows sample data for screenshots and videos?"

---

## Phase 2: Visual Assets

### 2.1 Remotion Promo Video
Created a 30-second promo video using Remotion (React-based video framework):

**Project Structure**:
```
shipshape-promo/
├── src/
│   ├── index.tsx              # Compositions registration
│   ├── ShipshapePromo.tsx     # Main video with scenes
│   ├── ProductDemo.tsx        # App simulation video
│   └── scenes/
│       ├── HookScene.tsx      # Problem statement
│       ├── SolutionScene.tsx  # Product reveal
│       ├── FeaturesScene.tsx  # Feature cards
│       └── CTAScene.tsx       # Call to action
```

**Key Techniques**:
- `spring()` for physics-based animations
- `interpolate()` for value mapping
- `TransitionSeries` for scene transitions with fades/slides
- `Sequence` for timing elements within scenes

**Prompt Pattern**: "Use remotion skills and send out subagents to learn how people use Claude Code to build great Remotion videos, then make me a promo video"

### 2.2 Product Demo GIF
Created a 10-second simulation of the app experience:
- Animated cursor moving to menubar
- Dropdown opening with spring animation
- Build status changing (yellow → green)
- Notification sliding in

**Conversion**: Remotion → MP4 → GIF using FFmpeg with palette optimization:
```bash
# Generate palette for better colors
ffmpeg -i input.mp4 -vf "fps=15,scale=600:-1:flags=lanczos,palettegen" palette.png

# Convert with palette
ffmpeg -i input.mp4 -i palette.png -filter_complex "fps=15,scale=600:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif
```

### 2.3 Screenshots
- Enabled demo mode in app
- Captured menubar with dropdown open
- Captured settings view
- Used for README and landing page

---

## Phase 3: Landing Page

### 3.1 Competitor Research
Used parallel subagents to analyze competitor landing pages:
- Raycast, CleanShot X, Bartender (menubar apps)
- Linear, Vercel (developer tools)
- iStat Menus, Warp (native Mac apps)

**Key Insights Applied**:
- Dark theme with vibrant status colors
- Product GIF prominent in hero (not static mockup)
- Comparison table (native vs Electron)
- Stats row (2MB, 10s polling, 20MB RAM)

### 3.2 Design System
```css
:root {
    /* Ocean depths palette */
    --navy-deep: #0a1628;
    --navy-mid: #122541;

    /* Copper/brass accents */
    --copper: #c87941;

    /* Status beacon colors */
    --beacon-green: #22c55e;
    --beacon-yellow: #eab308;
    --beacon-red: #ef4444;
}
```

### 3.3 Page Sections
1. **Hero**: Badge + headline + GIF + download CTA + stats
2. **Features**: 6-card grid with icons
3. **Comparison**: Table (Shipshape vs Electron)
4. **How It Works**: 3-step setup flow
5. **CTA**: Final download push

---

## Phase 4: Distribution

### 4.1 DMG Installer
```bash
# Create DMG with hdiutil
hdiutil create -volname "Shipshape" -srcfolder /path/to/app -ov -format UDZO Shipshape-1.0.0.dmg
```

### 4.2 GitHub Release
```bash
# Create release with DMG attachment
gh release create v1.0.0 ./Shipshape-1.0.0.dmg \
  --title "Shipshape 1.0.0" \
  --notes "Initial release..."
```

### 4.3 GitHub Pages Deployment
```bash
# Enable GitHub Pages via API
gh api repos/owner/repo/pages -X POST --input - <<'EOF'
{
  "build_type": "legacy",
  "source": { "branch": "main", "path": "/docs" }
}
EOF

# Set repo homepage
gh repo edit --homepage "https://owner.github.io/repo/"
```

### 4.4 Repo Metadata
```bash
gh repo edit --description "Native macOS menubar app for Vercel and Netlify deployment monitoring"
gh repo edit --add-topic macos,menubar,vercel,netlify,swiftui,deployment
```

---

## Phase 5: Marketing Prep

### 5.1 Social Media Drafts
Created ready-to-post content for:
- **Twitter/X**: Main launch tweet + thread
- **Reddit**: r/webdev, r/nextjs, r/sveltejs
- **Product Hunt**: Ship page copy
- **Hacker News**: Show HN post

### 5.2 Key Messaging Points
- Native SwiftUI (~2MB vs 90MB+ Electron)
- 10-second turbo polling during builds
- Monorepo-aware (skipped = gray, not red)
- Secure Keychain storage
- Free and open source

---

## Prompt Patterns That Worked

### 1. Spec-First Development
> "Build a native macOS menubar app that monitors Vercel and Netlify deployments with these features: [detailed list]"

### 2. Skill-Augmented Tasks
> "Use remotion skills and send out subagents to learn best practices, then build a promo video"

### 3. Competitive Research
> "Search the web for design inspiration from our best competitors, screenshot their designs, and build a superior design inspired by what they did"

### 4. Autonomous Execution
> "Do all of that" (after presenting a plan)

### 5. Demo Mode for Assets
> "Add a demo mode that shows sample data instead of my personal accounts"

### 6. End-to-End Automation
> "Can't you do this?" (for GitHub Pages setup that seemed manual)

---

## Tools & Technologies

| Category | Tools |
|----------|-------|
| **App Development** | Swift, SwiftUI, AppKit, Xcode |
| **Video Production** | Remotion, React, FFmpeg |
| **Distribution** | hdiutil (DMG), gh CLI (releases) |
| **Hosting** | GitHub Pages |
| **Research** | Subagents, web search |
| **Automation** | gh CLI, shell scripts |

---

## Checklist for Replication

### Pre-Launch
- [ ] Working product with demo mode
- [ ] Screenshots in demo mode
- [ ] Product demo GIF (10-15 seconds)
- [ ] Promo video (optional, 30 seconds)
- [ ] README with badges, features, installation
- [ ] LICENSE file
- [ ] Landing page with GIF, features, CTA

### Distribution
- [ ] DMG installer created
- [ ] GitHub release published
- [ ] GitHub Pages enabled
- [ ] Repo metadata updated (description, topics, homepage)

### Marketing
- [ ] Twitter post drafted
- [ ] Reddit posts drafted (target subreddits)
- [ ] Hacker News Show HN drafted
- [ ] Product Hunt page drafted

---

## Timeline

| Phase | Duration |
|-------|----------|
| Product development | ~1 hour |
| Demo mode + assets | ~20 min |
| Remotion video setup | ~30 min |
| Landing page | ~20 min |
| Distribution setup | ~15 min |
| Marketing drafts | ~10 min |
| **Total** | **~2.5 hours** |

---

## Key Takeaways

1. **Demo mode is essential** — Add it early for screenshots, videos, and testing
2. **Subagents for research** — Parallel competitor analysis saves time and improves output
3. **Remotion for videos** — Programmatic control beats manual video editing
4. **gh CLI for everything** — Releases, Pages, metadata all from terminal
5. **Prompt with intent** — "Do all of that" works when the plan is clear
6. **Don't assume manual** — Ask "can you do this?" for seemingly UI-only tasks

---

*This process shipped Shipshape from code to live landing page in a single Claude Code session.*
