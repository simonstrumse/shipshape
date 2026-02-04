# Shipshape Marketing Plan

*Keep your deploys shipshape.*

---

## Product Overview

**Shipshape** is a native macOS menubar app for monitoring Netlify and Vercel deployments in real-time.

### Key Differentiators

| Feature | Shipshape | Competitors |
|---------|-----------|-------------|
| **Native & Lightweight** | ~2MB SwiftUI | 90MB+ Electron |
| **Monorepo-Aware** | Skipped builds = gray (not red) | False error alerts |
| **Smart Error Handling** | 7-day recency window | Permanent red indicators |
| **Turbo Polling** | 10s during builds | 30-60s typically |
| **Unified View** | Active section shows all building | Per-service only |

### Target Users

1. **Indie developers** deploying to Vercel/Netlify
2. **Frontend teams** working on monorepos
3. **DevOps engineers** monitoring multiple projects
4. **Agencies** managing multiple client deployments

---

## Branding

### Name & Tagline
- **Name:** Shipshape
- **Tagline:** "Keep your deploys shipshape"
- **Alternative:** "Your deployment companion"

### Domain Strategy
| Priority | Domain | Status |
|----------|--------|--------|
| 1 | **shipshape.it** | ✅ Available — "Ship it!" developer phrase |
| 2 | getshipshape.app | Fallback |
| 3 | shipshape.app | Fallback |

### Visual Identity
- **Icon concept:** Small ship with colored flag (green/yellow/red)
- **Colors:** Navy blue + status colors (green, yellow, red, gray)
- **Style:** Minimal, macOS-native feel

---

## Launch Strategy

### Phase 1: Soft Launch (Week 1-2)
- [ ] Register domain (shipshape.it)
- [ ] Create simple landing page
- [ ] GitHub release (open source or binary)
- [ ] Share on Twitter/X with demo GIF
- [ ] Post to r/webdev, r/nextjs, r/sveltejs

### Phase 2: Product Hunt Launch (Week 3)
- [ ] Create Product Hunt listing
- [ ] Prepare launch assets:
  - Hero image (app in menubar, clean macOS desktop)
  - Gallery screenshots (menu open, settings, notifications)
  - Demo GIF (build starts → completes → notification)
- [ ] Write launch post copy
- [ ] Coordinate with hunter (or self-hunt)
- [ ] Schedule for Tuesday 12:01 AM PT (best launch day)

### Phase 3: Community Growth (Week 4+)
- [ ] Hacker News "Show HN" post
- [ ] Dev.to article: "Building a Native macOS Menubar App with SwiftUI"
- [ ] YouTube demo video
- [ ] Add to awesome-vercel, awesome-netlify lists

---

## Product Hunt Launch Assets

### Tagline (60 chars max)
```
Native macOS app for Vercel & Netlify deployment monitoring
```

### Description (260 chars max)
```
Shipshape is a lightweight menubar app that monitors your Vercel and Netlify deployments. Native SwiftUI, turbo polling during builds, and smart monorepo support. Know instantly when deploys finish or fail.
```

### First Comment (by maker)
```
Hey Product Hunt! 👋

I built Shipshape because I was tired of:
- Keeping browser tabs open to check deploy status
- Electron apps eating 300MB+ of RAM
- Getting false "failed" alerts for skipped monorepo builds

Shipshape is:
✅ Native SwiftUI (~2MB vs 90MB Electron)
✅ Polls every 10 seconds during active builds
✅ Smart about monorepos (skipped ≠ failed)
✅ Shows build duration inline

Would love your feedback! What features would make this essential for your workflow?
```

### Gallery Images Needed
1. **Hero:** Clean desktop with menubar showing green status
2. **Menu Open:** Active section with building + recent deploys
3. **Notifications:** macOS notification "vibelabs deployed successfully"
4. **Settings:** Account configuration screen
5. **Comparison:** Side-by-side with Electron competitor showing memory usage

---

## Pricing Strategy

### Option A: Free & Open Source
- **Pros:** Community growth, contributions, trust
- **Cons:** No revenue, support burden
- **Model:** GitHub Sponsors for donations

### Option B: Freemium
- **Free:** Up to 3 projects
- **Pro ($4.99 one-time):** Unlimited projects, priority support
- **Pros:** Sustainable, fair value
- **Cons:** App Store review, payment handling

### Option C: Paid Only ($4.99)
- **Pros:** Filters to serious users, sustainable
- **Cons:** Friction, harder launch traction

**Recommendation:** Start with **Option A (Free & Open Source)** for launch traction, add **Pro tier** later via Gumroad/Paddle if demand exists.

---

## Competitive Landscape

### Direct Competitors

| App | Platform | Tech | Price | Notes |
|-----|----------|------|-------|-------|
| **Shiplog** | Mac/Win | Electron | Free | Open source, heavy |
| **Deploy Status for Netlify** | Mac | Native | Free/$4.99 | Netlify only |
| **Deploy Status for Vercel** | Mac | Native | Free | Vercel only |
| **Zeitgeist** | iOS | SwiftUI | Free | iOS only, real-time |

### Positioning
Shipshape is the **only native macOS app** that:
1. Supports **both** Vercel and Netlify
2. Has **monorepo-aware** status detection
3. Offers **turbo polling** during builds
4. Shows **unified "Active" view** across services

---

## Future Roadmap

### v1.1 - Polish
- [ ] Custom app icon
- [ ] Keyboard shortcuts (Cmd+R refresh)
- [ ] Sound alerts option

### v1.2 - Real-Time
- [ ] Vercel streaming events API integration
- [ ] Even faster updates during builds

### v1.3 - Power Features
- [ ] Multiple accounts per service
- [ ] Project filtering/favorites
- [ ] Build time analytics

### v2.0 - Push Notifications (requires backend)
- [ ] APNs integration for true real-time
- [ ] Webhook receiver service
- [ ] Optional paid tier for push notifications

---

## Success Metrics

### Launch Goals
- [ ] 500+ Product Hunt upvotes
- [ ] 100+ GitHub stars (if open source)
- [ ] 50+ Twitter mentions

### Growth Goals (3 months)
- [ ] 1,000+ active users
- [ ] 10+ community contributions
- [ ] Featured in 3+ newsletters

---

## Content Calendar

### Week 1: Pre-Launch
- **Mon:** Finalize app, record demo GIF
- **Tue:** Create landing page
- **Wed:** Write Product Hunt copy
- **Thu:** Prepare gallery assets
- **Fri:** Soft launch on Twitter

### Week 2: Build Hype
- **Mon:** Dev.to article draft
- **Tue:** Product Hunt ship page live
- **Wed:** Share teaser on Twitter
- **Thu:** Reach out to tech newsletters
- **Fri:** Final testing

### Week 3: Launch
- **Tue 12:01 AM PT:** Product Hunt live
- **Tue morning:** HN "Show HN" post
- **Tue-Wed:** Engage with comments
- **Thu:** Reddit posts
- **Fri:** Launch retrospective

---

## Resources Needed

### Design
- [ ] App icon (1024x1024)
- [ ] Landing page design
- [ ] Product Hunt gallery images

### Development
- [ ] Polish UI details
- [ ] Test on multiple macOS versions
- [ ] Create DMG installer

### Marketing
- [ ] Demo GIF/video
- [ ] Social media graphics
- [ ] Press kit

---

## Notes

### Why "Shipshape"?
- Double meaning: "shipping code" + "everything in order"
- Positive connotation (vs fear-based naming)
- Memorable, single word
- Nautical theme fits DevOps (Docker, Kubernetes, Helm)

### Known Brand Conflicts
- shipshape.dev (Vercel dashboard tool) - different product category
- shipshape.io (JS consultancy) - different industry
- Decision: Proceed anyway, our product is distinct enough

### Technical Moat
- Native SwiftUI expertise (most devs don't know Swift)
- Monorepo detection logic (non-obvious implementation)
- Smart polling algorithm (balances updates vs resources)
