# LinkedIn Post

---

## Version 1: Story-focused (Recommended)

**I shipped a complete product launch in one afternoon using Claude Code.**

Not just the code — the *entire* launch:

- DMG installer → GitHub Releases
- Landing page → Live on GitHub Pages
- 30-second promo video (with music!)
- Animated product demo GIF
- Social posts for Twitter, Reddit, HN
- README, LICENSE, repo metadata

The product: Shipshape, a native macOS menubar app for monitoring Vercel and Netlify deployments.

Here's what surprised me:

**1. Programmatic video beats screen recording**
Instead of capturing my screen, Claude built a simulated app demo in Remotion (React for video). Perfect timing, version-controlled, iteratable.

**2. Research agents before execution**
I asked Claude to analyze competitor landing pages first. It spawned subagents that studied Raycast, Linear, Vercel, and CleanShot X — then synthesized the patterns into a better design.

**3. "Manual" tasks aren't manual**
When I said "go to GitHub Settings to enable Pages," Claude replied: "Can't I just do that?"

Yes. The gh CLI can programmatically enable GitHub Pages, create releases, set repo metadata. No clicking required.

**4. Demo mode is essential**
Adding a toggle to show fake data for screenshots/videos was trivial but made all the difference for asset creation.

The traditional launch checklist — landing page, video, installer, marketing copy — would take a weekend. This took 2.5 hours.

I documented the full process for anyone who wants to replicate it.

The app is free and open source:
https://github.com/simonstrumse/shipshape

---

#buildinpublic #claudecode #ai #macos #swiftui #devtools #shipping

---

## Version 2: Technical achievement focus

**I automated an entire product launch with Claude Code.**

In one session:
→ Created DMG installer (hdiutil)
→ Published GitHub release (gh CLI)
→ Built 30-second promo video (Remotion)
→ Generated optimized GIF (FFmpeg + palette)
→ Deployed landing page (GitHub Pages API)
→ Drafted posts for Twitter, Reddit, HN

The product: Shipshape — a native macOS menubar app for Vercel/Netlify deployment monitoring.

The workflow that impressed me most:

1. **Subagent research**: Claude spawned agents to analyze competitor landing pages (Raycast, Linear, Vercel) and synthesized design patterns before building.

2. **Programmatic video**: Instead of screen recording, built a simulated app demo in Remotion. The cursor movement, dropdown animation, build status change — all coded. Version-controlled. Iteratable.

3. **Zero UI clicks**: GitHub Pages enabled via `gh api`, release created via `gh release create`, repo metadata set via `gh repo edit`. Everything from terminal.

4. **FFmpeg for GIF optimization**: Palette generation for crisp colors at small file sizes:
```
ffmpeg -i input.mp4 -vf "palettegen" palette.png
ffmpeg -i input.mp4 -i palette.png -filter_complex "paletteuse" output.gif
```

Total time: ~2.5 hours of prompting.

The traditional checklist (landing page, video, installer, copy) would be a weekend project. This was an afternoon.

Full process documented here: [link to article]

App is free and open source:
https://github.com/simonstrumse/shipshape

---

#claudecode #ai #automation #devtools #macos #swiftui #shipping

---

## Version 3: Short and punchy

**Shipped a full product launch in one Claude Code session:**

✓ Native macOS app with demo mode
✓ 30-second promo video (Remotion)
✓ Animated product GIF
✓ Landing page (live on GitHub Pages)
✓ DMG installer on GitHub Releases
✓ Social media drafts for 4 platforms

What would've been a weekend of Figma + Premiere + manual uploads = 2.5 hours of prompting.

The secret sauce:
• Subagents researching competitors before designing
• Programmatic video instead of screen recording
• gh CLI for *everything* GitHub (releases, Pages, metadata)

Shipshape is free: https://github.com/simonstrumse/shipshape

Full process breakdown in comments.

---

#buildinpublic #claudecode #shipping

---

## Suggested Image/Carousel

**Slide 1**: Hero image of Shipshape landing page
**Slide 2**: Screenshot of the Remotion project structure
**Slide 3**: The product demo GIF
**Slide 4**: Terminal showing gh CLI commands
**Slide 5**: "2.5 hours → Full launch" summary graphic

---

## Hashtag Options

Primary: #claudecode #buildinpublic #ai #shipping
Secondary: #macos #swiftui #devtools #indiedev #solopreneur
Technical: #remotion #github #automation
