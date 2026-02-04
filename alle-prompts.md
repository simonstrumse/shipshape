# Alle Prompts: Fra Idé til Lansering

> Komplett dokumentasjon av alle prompts brukt for å bygge og lansere Shipshape med Claude Code.

---

## Fase 1: App-utvikling

### Prompt 1: Initial Plan
```
Implement the following plan:

# Netlify + Vercel Statusbar App - Research & PRD Plan

## Executive Summary
Build a macOS statusbar app that monitors Netlify and Vercel deployments
with real-time notifications...
```
*Claude bygde hele grunnstrukturen basert på en detaljert plan.*

---

### Prompt 2: Sortering
```
so now I have those two dropdowns in the menubar which is great. but the
projects are sorted alphabetically, not chronologically. I want the latest
one on top.
```

---

### Prompt 3: Active Section
```
also I want the ones that are actually building, and have just finished
building. so all the ones I'm working on today to show in a separate section
on top of those dropdowns, so I don't need to think vercel or netlify - i can
have a build running in vercel and in netlify at the same time, and see both
of them on the top.
```

---

### Prompt 4: Monorepo-problem
```
one issue I have now is that the indicator shows red when the error is not the
latest build but before that - and it's not actually a build error, it's just
that it skipped deploy / canceled deploy because it was part of a monorepo
with no changes - any ideas on how to improve on this?
```

---

### Prompt 5: Debug
```
i rebuilt and it still shows a red indicator for this older skipped build -
try and figure it out?
```

---

### Prompt 6: Fortsatt debug
```
dropdown correctly showing grey skipped - menubar indicator still showing red
```

---

### Prompt 7: Turbo Polling
```
is there a way we can fetch the exact building cycle, or notify as soon as
it's done building? more often polling (poll more often just after it's
detected a build started, and until build finished or for 2 minutes after
build started...) other ideas?
```

---

### Prompt 8: Prosjektgrense
```
vercel is showing 20 projects and netlify 38 - but i know vercel has way more.
why only showing 20? I don't mean that I want to show more. i just want to know
if it's a limitation put on our end or their end
```

---

### Prompt 9: Show More
```
yes add limit 100 but show only top 20 in the first view of the dropdown,
with maybe a view more at the end of the list
```

---

## Fase 2: Branding

### Prompt 10: Navneforslag
```
brainstorm great names for this app - base yourself maybe on some of the
research you did and what names work great on product hunt
```

---

### Prompt 11: Shipshape Research
```
yes - also do the research on the shipshape branding, best domains
available etc.
```

---

### Prompt 12: Konkurrentanalyse
```
what does this app have that shiplog doesn't have? I'm tempted to just
download and use shiplog instead of this one. actually do install it for
me so I can test them side by side
```

---

### Prompt 13: Bekreftelse + UI
```
ok. mine is actually better. go back to planning the domain and branding
for shipshape but also look at if we can add these to our very neat ui
without bloating it or adding any lines etc. be smart about it
```

---

## Fase 3: Lansering

### Prompt 14: Autonomt Ship ⭐
```
ok. now how many of the next steps list can you do autonomously or
semiautonomously using the chrome extension, remotion skill web searches
to learn how to best solve these problems with claude code, and screenshots
and whatever. Let's see you ship it
```
*Dette var vendepunktet - Claude tok over lanseringen.*

---

### Prompt 15: Lanserings-plan
```
Implement the following plan:

# Ship It: Autonomous Launch Tasks

## Overview
Execute as many launch tasks as possible autonomously using available tools.

- Create landing page
- GitHub release with DMG
- Create demo GIF
- Update README
- Draft social media posts
...
```

---

### Prompt 16: Remotion Video ⭐
```
can you use remotion skills - and send out some subagents to learn how
people use claude code to build great remotion videos - and then make me
a promovideo using remotion?
```
*Claude sendte ut research-agenter og bygde en 30-sekunders promo.*

---

### Prompt 17: Video-feedback
```
regarding the video - this text is not very visible when it is on top of
the product showing things are badly aligned here - all in all the video
itself is good, but stuff is a bit small, tags and texts and things are
a bit small - maybe you can align things better - make sure all text is
more visible etc and make a new version - could you also generate and
add music to it
```

---

### Prompt 18: Screenshot + GIF
```
here is the screenshot Desktop/ScreenshotOrganizer/inbox/Screenshot
2026-02-04 at 15.40.10.png' and here is a video you can turn into a gif
'/Users/simonsouyrisstrumse/Desktop/ScreenshotOrganizer/inbox/Screen
Recording 2026-02-04 at 15.45.14.mov'
```

---

### Prompt 19: Produkt-demo GIF
```
ok. can you now use remotion to make a video demo of the product - like
what you wanted to have in the gif. make a remotion video that just shows
how the product works and turn this into a gif
```

---

### Prompt 20: Konkurrent-research + Design ⭐
```
yes do all of that feel free to search the web to get design inspirations
from our best competitors, screenshot their designs and build us a unique
and superior design but inspired by what they thought about
```
*Claude analyserte Raycast, Linear, CleanShot X, Vercel og bygde landingssiden.*

---

### Prompt 21: GitHub Pages
```
cant you do this? To Deploy to GitHub Pages

After pushing to GitHub, enable Pages in your repo settings:
1. Go to Settings → Pages
2. Under "Source", select Deploy from a branch
3. Choose main branch and /docs folder
4. Click Save
```
*Claude gjorde det programmatisk via gh API.*

---

### Prompt 22: Dokumentasjon
```
this is so awesome - now in this session and chat you almost automated
shipping a full product with claude code - after making the product in a
few prompts with me on my spec you created the videos, the gifs, the website,
the copy, the marketing copy etc. and even prepped a lot of things for
product hunt. please document it all both in like an .md for use in the
future to replicate the process, but also as an article, with a linkedin
post that goes with it where you brag a bit about how we did it
```

---

### Prompt 23: Kort historie
```
make a short story talking about how it made all the marketing material,
all the marketing strategy and then how it shipped itself
```

---

### Prompt 24: LinkedIn (Norsk)
```
dette er jo litt outline på linkedin + andre plattformer historien jeg vil
fortelle: Jeg gjorde et veldig kult eksperiment i dag. Ga claude code en
retning og en visjon. Den bygde Mac appen på et prompt - deretter etter et
prompt markedsføringsvideo, nettside, screenshots, animerte Gifer, linkedin
posts, og lanserte seg selv… så fra ide til lansering i 3-4 (veldig korte
prompt) kan du skrive den med riktig kontekst som er her
```

---

### Prompt 25: Vercel Deploy
```
også husk å deploye landingssiden til vercel - gjør de siste next stepsene
for lansering
```

---

### Prompt 26: Ekte lenker
```
med ekte lenke til dmg-en
```

```
eller githuben ihvertfall
```

---

### Prompt 27: Denne dokumentasjonen
```
kan du dokumentere alle promptene jeg skrev i dette prosjektet fra den
første til den siste?
```

---

## Oppsummering

| Fase | Antall Prompts | Resultat |
|------|----------------|----------|
| App-utvikling | 9 | Fungerende macOS-app |
| Branding | 4 | Navn, logo-konsept, konkurrentanalyse |
| Lansering | 14 | Video, GIF, landingsside, GitHub release, sosiale medier |
| **Totalt** | **27** | **Komplett produkt lansert** |

---

## Nøkkel-prompts

De mest effektive promptene var:

1. **"Let's see you ship it"** — Ga Claude autonomi til å ta beslutninger
2. **"send out subagents to learn..."** — Brukte research-agenter før implementering
3. **"can't you do this?"** — Utfordret antakelser om hva som krever manuelt arbeid
4. **"do all of that"** — Bekreftet planer uten å mikromanage

---

## Lenker

- **Landingsside**: https://shipshape-app.vercel.app
- **GitHub**: https://github.com/simonstrumse/shipshape
- **DMG**: https://github.com/simonstrumse/shipshape/releases/download/v1.0.0/Shipshape-1.0.0.dmg
