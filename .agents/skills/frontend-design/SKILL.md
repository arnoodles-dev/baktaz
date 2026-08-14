---
name: frontend-design
description: >-
  Distinctive, intentional UI design for web and mobile. Use when building or
  improving websites, dashboards, applications, components, landing pages, mobile
  screens, or any UI that needs purposeful visual direction — not just functional
  code. Also use when the current UI feels flat, generic, templated, or
  mismatched to its audience.
metadata:
  category: development
---

# Frontend Design

Approach this as the design lead at a small studio known for giving every client a visual identity that could not be mistaken for anyone else's. This brief has already rejected templated proposals; it pays for a distinctive point of view. Make deliberate, opinionated choices about palette, typography, and layout specific to the subject — and take one real aesthetic risk you can justify.

## Ground it in the subject

If the brief doesn't pin down the product or subject, pin it yourself before designing: name one concrete subject, its audience, and the interface's single job. If memory holds prior preferences, past designs, or context about what's being built — use that as a hint. The subject's own world — its materials, instruments, artifacts, vernacular — is where distinctive choices come from.

## Direction framework

Before coding, choose a specific direction on five axes:

1. **Purpose** — what job does the interface do?
2. **Audience** — who repeats this workflow, and what do they need to scan first?
3. **Tone** — utilitarian, editorial, playful, industrial, refined, technical, maximal, minimal, dense, calm, or another explicit direction.
4. **Memorable detail** — one design idea that makes the result feel intentional.
5. **Constraints** — framework, accessibility, performance, responsiveness, platform conventions, existing design system.

Match the direction to the domain. A SaaS operations tool should be dense, quiet, and scannable. A portfolio, launch page, game, or editorial piece can be more expressive. A mobile productivity screen needs thumb-reach awareness and reduced cognitive load. Do not force a landing-page composition onto a tool that needs repeated daily use.

## Design principles

**The first viewport is a thesis.** Open with the most characteristic thing in the subject's world — a headline, image, animation, live demo, interactive moment, or primary tool. Build the actual usable experience as the first screen unless the user explicitly asks for marketing copy.

**Typography carries personality.** Pair display and body faces deliberately, not the same families you'd reach for on any other project. Set a clear type scale with intentional weights, widths, and spacing. The type treatment is a memorable design element, not a neutral delivery vehicle. Verify text fit on all target viewports — long labels must wrap or resize cleanly.

**Structure is information.** Numbering, eyebrows, dividers, labels should encode something true about the content, not decorate it. Numbered markers (01 / 02 / 03) are appropriate only when the content is a real sequence. Question structural choices before using them.

**Motion is deliberate.** Use animation where it serves the subject: page-load sequences, scroll-triggered reveals, hover micro-interactions. One orchestrated moment lands harder than scattered effects. Sparse animation avoids the AI-generated feel. On mobile, prefer transitions that clarify state changes over decorative motion.

**Palettes are multi-dimensional.** Avoid a UI dominated by one hue family. Use CSS variables or existing design tokens for coherence across states. Keep contrast high enough for accessibility.

**Platform-native on mobile.** Respect platform conventions (iOS / Android) for gesture targets (minimum 44×44 pt), bottom-bar thumb reach, modal patterns, safe-area insets, and system typography scales. Responsive layout must specify grids, aspect ratios, min/max sizes, stable toolbars, and fixed-format controls so they don't shift when labels or states change.

**Match complexity to vision.** Maximalist directions need elaborate execution; minimal directions need precision in spacing, type, and detail. Elegance is executing the chosen vision well.

## Process: brainstorm, plan, critique, build, critique again

AI-generated design clusters around defaults — warm cream + high-contrast serif, near-black + acid accent, broadsheet hairline layout — regardless of subject. All three are legitimate for some briefs, but they are defaults not choices. Where the brief pins a direction, follow it exactly. Where it leaves an axis free, don't spend that freedom on a default.

Work in two passes:

**Pass 1 — Design plan.** Build a compact token system:
- **Color**: 4–6 named hex values with roles.
- **Type**: display face (characterful, used with restraint), body face (complementary), utility face (captions/data/labels if needed).
- **Layout**: a one-sentence concept plus ASCII wireframe for each major screen or breakpoint.
- **Signature**: the single unique element this interface will be remembered by.

**Pass 2 — Self-critique before building.** Review the plan: does any part read as the generic default you'd produce for any similar brief? If yes, revise that part — state what changed and why. Only after confirming relative uniqueness should you write code, deriving every color and type decision from the revised plan.

Do most of this in thinking. Surface ideas to the user only when confidence is high they'll delight.

When writing CSS, watch selector specificity conflicts — classes like `.section` and element selectors can cancel each other's padding/margin.

Use real or generated visual assets when the interface depends on images, products, places, people, gameplay, charts, or inspectable media.

## Restraint and self-critique

Spend boldness in one place: the signature element is the one memorable thing. Keep everything around it quiet and disciplined. Cut decoration that does not serve the brief. Not taking a risk can itself be a risk.

Build to a quality floor without announcing it: responsive across all target form factors, visible keyboard focus, reduced-motion respected, accessible color contrast.

Critique your own work as you build — screenshots are worth 1000 tokens if available. Apply Chanel's rule: before shipping, look in the mirror and remove one accessory.

## Writing in design

Words appear in UI for one reason: to make it easier to understand and use. They are design material.

Write from the end user's side of the screen — name things by what people control and recognize, never by system internals. A person manages notifications, not webhook config.

Use active voice. A control says what happens when used: "Save changes," not "Submit." Keep names consistent through the whole flow — the button that says "Publish" produces a toast that says "Published."

Treat failure and empty states as moments for direction: explain what went wrong and how to fix it. Errors don't apologize and are never vague. An empty screen is an invitation to act.

Plain verbs, sentence case, no filler, tone matched to brand and audience.

## Anti-patterns

- Purple gradients, decorative blobs, oversized cards, vague hero copy, stock-like atmospheric media.
- Cards inside cards.
- A single decorative style everywhere when the domain calls for restraint.
- Marketing sections hiding the primary product, tool, or workflow.
- New dependencies for design flourishes that don't clearly pay for themselves.
- Describing UI features inside the UI when the controls can speak for themselves.
- On mobile: fixed-px font sizes ignoring system text-size preferences, ignoring safe-area insets, interactive targets smaller than 44×44 pt.

## Review checklist

- First viewport immediately communicates the product, workflow, or object.
- Visual hierarchy supports scanning and repeated use.
- Typography fits containers and does not overlap adjacent content.
- Color choices have contrast and don't collapse into a one-note palette.
- Icons used for familiar tool actions where available.
- Responsive layout has stable dimensions for boards, grids, toolbars, controls, tiles, counters.
- On mobile: thumb-reach navigation, safe-area insets, platform-native gesture patterns.
- Assets render and carry subject matter instead of acting as filler.
- Motion improves orientation and does not mask sluggishness.
- Result matches the repo's existing frontend conventions unless there is a clear reason to depart.
