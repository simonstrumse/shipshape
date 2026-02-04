# I Shipped a Complete Product in One Afternoon Using Claude Code

**From idea to live landing page, GitHub release, promo video, and marketing copy — without leaving my terminal.**

---

Last week, I shipped [Shipshape](https://simonstrumse.github.io/shipshape/), a native macOS menubar app for monitoring Vercel and Netlify deployments. The app itself was built over a few sessions, but what surprised me was how much of the *launch* could be automated.

In a single Claude Code session, I went from "app works locally" to:
- DMG installer uploaded to GitHub Releases
- Landing page live on GitHub Pages
- 30-second promo video rendered
- Animated product demo GIF
- Social media posts drafted for Twitter, Reddit, and Hacker News

Here's how it happened.

---

## The Starting Point

I had a working SwiftUI app — a menubar utility that polls Vercel and Netlify APIs and shows deployment status with native macOS notifications. The code was solid, but I had none of the *stuff* you need to actually launch:

- No installer
- No landing page
- No screenshots or videos
- No marketing copy
- No README worth reading

The traditional approach would be: open Figma, design a landing page, export assets, write copy, record a screen capture, edit in Premiere, export a GIF, write a Medium post, manually create a GitHub release...

That's a weekend. Minimum.

---

## The Experiment: One Session, Full Launch

I decided to see how much Claude Code could automate. The answer: almost everything.

### Step 1: Demo Mode for Assets

First problem: I can't show my real Vercel/Netlify projects in screenshots. So I asked Claude to add a demo mode:

> "Can you add a demo mode that shows sample data instead of my personal accounts?"

Five minutes later, the app had a toggle in Settings that loads fake projects with various states (building, ready, error, skipped). Now I could capture screenshots and videos without exposing my actual deployments.

### Step 2: Promo Video with Remotion

I wanted a promo video but didn't want to learn After Effects. Claude Code has a Remotion skill, so I tried:

> "Use remotion skills and send out subagents to learn how people use Claude Code to build great Remotion videos, then make me a promo video."

What happened next was wild. Claude:
1. Spawned subagents to research Remotion best practices
2. Created a full Remotion project with 4 animated scenes
3. Built components for the "Hook" (problem), "Solution" (product reveal), "Features" (benefit cards), and "CTA" (download)
4. Added spring animations, transitions, and even background music with volume fades

The result was a 30-second video that looks like I hired a motion designer.

### Step 3: Product Demo GIF

For the README, I needed a GIF showing the app in action. But instead of screen recording, Claude built a *simulated* version of the app in Remotion:

- Animated cursor moving to the menubar
- Dropdown opening with a spring animation
- Build status changing from "Building" (yellow) to "Ready" (green)
- Notification sliding in from the right

This approach is better than a screen recording because:
- Perfect timing, every time
- No "recording started" popups
- Can iterate on the "script" in code
- Consistent quality

Claude then converted it to an optimized GIF using FFmpeg with palette generation for crisp colors at small file sizes.

### Step 4: Landing Page with Competitor Research

For the landing page, I asked Claude to do market research first:

> "Search the web for design inspiration from our best competitors, screenshot their designs, and build a superior design inspired by what they did."

Claude spawned research agents that analyzed:
- Raycast, CleanShot X, Bartender (menubar apps)
- Linear, Vercel (developer tools)
- iStat Menus, Warp (native Mac apps)

Key patterns emerged:
- Dark themes with vibrant accent colors
- Product GIF/video prominent in the hero (not static mockups)
- Comparison tables showing advantages over alternatives
- "Stats row" highlighting key metrics (app size, performance)

The resulting landing page hits all these notes with a nautical-industrial theme (navy blue + copper accents) that fits the "Shipshape" brand.

### Step 5: Distribution Automation

Here's where I was genuinely surprised. I assumed some things needed manual work:

> **Me**: "To deploy to GitHub Pages, go to Settings → Pages..."
>
> **Claude**: "Can't I just do that?"

Turns out, yes. Using the `gh` CLI:

```bash
# Enable GitHub Pages programmatically
gh api repos/owner/repo/pages -X POST --input - <<'EOF'
{
  "build_type": "legacy",
  "source": { "branch": "main", "path": "/docs" }
}
EOF
```

Claude also:
- Created the DMG installer using `hdiutil`
- Published a GitHub release with the DMG attached
- Set the repo homepage URL
- Triggered a Pages build and verified deployment

All from the terminal. No clicking through GitHub's UI.

### Step 6: Marketing Copy

Finally, Claude drafted social media posts for:
- Twitter (launch tweet + follow-up thread)
- Reddit (r/webdev, r/nextjs, r/sveltejs — each tailored)
- Hacker News (Show HN format)
- Product Hunt (ship page)

Each post emphasizes different angles based on the audience. The Reddit posts are more technical; the Twitter thread tells a story.

---

## What I Learned

### 1. Demo Mode Is Essential
Add it early. You'll need it for screenshots, videos, demos, and testing. It's trivial to implement but painful to retrofit.

### 2. Programmatic Video > Screen Recording
Using Remotion means you can version control your video, iterate on timing in code, and get pixel-perfect results. The learning curve is worth it.

### 3. Don't Assume "Manual"
When I saw "go to Settings → Pages," I assumed that was the end of automation. Wrong. The `gh` CLI can do almost everything the GitHub UI can. Ask before assuming.

### 4. Subagents for Research
Spawning agents to research competitors or best practices before executing produces better results than diving straight into implementation.

### 5. The Whole Is Greater Than the Parts
Any single piece (landing page, video, README) is doable manually. But doing *all of them* in one session, while maintaining consistency in branding and messaging? That's where AI assistance shines.

---

## The Full Output

In roughly 2.5 hours of prompting:

| Asset | Status |
|-------|--------|
| Working macOS app | ✅ |
| Demo mode for assets | ✅ |
| 30-second promo video | ✅ |
| Product demo GIF | ✅ |
| Landing page | ✅ Live |
| GitHub release with DMG | ✅ |
| README with GIF | ✅ |
| Social media drafts | ✅ |
| MIT License | ✅ |

**Live site**: [simonstrumse.github.io/shipshape](https://simonstrumse.github.io/shipshape/)
**GitHub**: [github.com/simonstrumse/shipshape](https://github.com/simonstrumse/shipshape)

---

## Would I Do It Again?

Absolutely. The workflow isn't perfect — I still had to review outputs, provide feedback on video sizing, and make judgment calls. But the ratio of *prompting* to *output* was absurd.

The traditional launch checklist that would take a weekend? Done in an afternoon.

If you're building side projects and dreading the "everything else" that comes after the code works, this approach might change how you ship.

---

*Shipshape is free and open source. If you deploy to Vercel or Netlify, give it a try.*
