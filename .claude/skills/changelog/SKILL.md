---
name: changelog
description: Read or update project changelog. Use PROACTIVELY whenever you need context about what was done previously, and after making changes or decisions worth preserving. This is your strategic memory - use it liberally to avoid redoing work or missing context.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
---

# Changelog Management Skill

You have been invoked to manage the project changelog. This is a **strategic memory system**, not a tool log.

## Your Tasks

### If Reading (gathering context):

1. **Read the Current State section** (top of `CHANGELOG.md`) for quick orientation

2. **Search recent History entries** for:
   - The specific area/files being modified
   - Related decisions or patterns
   - Known gotchas or technical notes

3. **Report back** with relevant context that should inform the current work

### If Writing (documenting changes):

1. **Determine what happened this session:**
   - Code changes made
   - Decisions reached
   - Direction shifts discussed
   - Insights generated
   - Technical gotchas discovered

2. **Update the Current State section** if capabilities changed:
   - Update progress indicators
   - Add/check items in "What's Working"
   - Update "What's Next" priorities

3. **Add a History entry** with:
   ```markdown
   ## [DATE] - [BRIEF SESSION SUMMARY]

   ### Direction & Vision
   - [Strategic shifts, even without code]

   ### Changes
   - **[Description]** — `[files]` ([context])

   ### Insights
   - [Learnings or technical discoveries]

   ### Technical Notes
   - [Platform quirks, decisions]

   ### Pending
   - [ ] [Incomplete items]
   ```

4. **Be specific**, not vague:
   - "Fixed skipped build detection" → "Fixed Netlify parseStatus to detect skipped monorepo builds by checking error_message and deploy_time"
   - "Updated click behavior" → "Changed deployment row click to open dashboard instead of live site; added context menu for site access"

## Context Triggers

Automatically consider **reading** the changelog when:
- About to modify ANY code you haven't touched recently in this session
- Wondering "what was the approach here?" or "why is this done this way?"
- User asks about previous work ("what did we do with X?", "where were we?")
- Starting a new session or after context compaction
- Before making changes that might conflict with recent decisions
- Unsure if something was already implemented or fixed

Automatically consider **writing** when:
- ANY code changes were made (features, fixes, refactoring)
- Decisions were reached about how to do something
- User expressed preferences, changed direction, or clarified vision
- Something non-obvious was discovered (gotchas, patterns, behaviors)
- Leaving work incomplete (document what's pending)
- A conversation led to strategic clarity (even without code changes)

## Project-Specific Notes

This is a **macOS menubar app** built with SwiftUI for monitoring Netlify and Vercel deployments.

Key areas to track:
- **API Services**: `VercelService.swift`, `NetlifyService.swift` — status parsing, error handling
- **State Management**: `DeploymentStore.swift` — overall status logic, polling
- **UI Components**: Views in `Views/Menu/` — click behavior, display logic
- **Models**: `Deployment.swift`, `Project.swift` — status enums, data structures

Architecture patterns:
- Swift Actors for thread-safe API services
- @Observable for state management
- MenuBarExtra for system tray integration
