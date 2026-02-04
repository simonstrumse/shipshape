# The App That Shipped Itself

I built an app. Then I asked Claude Code to ship it.

It did.

---

## The Marketing Machine

It started with a simple ask: "Make me a promo video."

Claude didn't open After Effects. It didn't ask me to record my screen. Instead, it built a video *in code* — a full Remotion project with four animated scenes, spring physics, transitions, and background music that fades in and out.

Thirty seconds of polished motion graphics. From a prompt.

Then came the GIF. But not a screen recording — a *simulation* of the app. Claude coded an animated cursor clicking the menubar, a dropdown springing open, a build status changing from yellow to green, a notification sliding in. Frame-perfect. Repeatable. Version-controlled.

I asked for a landing page. Claude asked to do research first.

It spawned agents — plural — to analyze competitor websites. Raycast. Linear. CleanShot X. Vercel. They came back with patterns: dark themes, GIFs in heroes, comparison tables, stats rows. Claude synthesized it all into a single-page site with a nautical-industrial aesthetic that I never would have designed myself.

Then the copy. Twitter drafts. Reddit posts tailored to r/webdev, r/nextjs, r/sveltejs. A Hacker News "Show HN" submission. Product Hunt ship page. Each one hitting different angles for different audiences.

All the marketing. From prompts.

---

## The Self-Shipping

Here's where it got weird.

I looked at my checklist:
- Create DMG installer
- Upload to GitHub Releases
- Enable GitHub Pages
- Set repo homepage URL

Standard launch stuff. Manual stuff. *Click-through-the-UI* stuff.

I started typing instructions: "To deploy to GitHub Pages, go to Settings, then Pages, then—"

Claude interrupted: "Can't I just do that?"

I blinked.

It could.

```bash
# Create the installer
hdiutil create -volname "Shipshape" -srcfolder app.app Shipshape.dmg

# Publish the release
gh release create v1.0.0 ./Shipshape.dmg --title "Shipshape 1.0.0"

# Enable GitHub Pages
gh api repos/owner/repo/pages -X POST --input - <<'EOF'
{"source": {"branch": "main", "path": "/docs"}}
EOF

# Set the homepage
gh repo edit --homepage "https://owner.github.io/repo/"
```

It packaged the app. Uploaded the installer. Enabled the hosting. Configured the metadata. Triggered the build. Verified the deployment.

The landing page went live at `simonstrumse.github.io/shipshape`.

I didn't click a single button.

---

## The Punchline

In one afternoon:

| What | How |
|------|-----|
| Promo video | Coded in Remotion |
| Demo GIF | Simulated, not recorded |
| Landing page | Designed after competitor research |
| Twitter post | Drafted |
| Reddit posts (x3) | Drafted and tailored |
| HN submission | Drafted |
| Product Hunt copy | Drafted |
| DMG installer | Created with hdiutil |
| GitHub release | Published via CLI |
| GitHub Pages | Enabled via API |
| Repo metadata | Set programmatically |

The app didn't just get built.

It got *marketed*.

It got *packaged*.

It got *deployed*.

It shipped itself.

---

## What This Means

The bottleneck for side projects was never the code. It was everything else — the landing page you never make, the video you never edit, the installer you never package, the posts you never write.

That bottleneck is gone.

Not reduced. *Gone.*

The app is live: [shipshape](https://simonstrumse.github.io/shipshape/)

It monitors your Vercel and Netlify deploys from the menubar.

It's free.

And it shipped itself.
