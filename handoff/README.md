# DoTo — Spatial Glass · developer handoff

Everything needed to build the redesign in Flutter.

```
handoff/
├── README.md            ← this file
├── DESIGN_SPEC.md       ← tokens, type scale, geometry, every component + state, data model
├── doto_theme.dart      ← drop-in: DotoColors ThemeExtension, text styles, GlassSurface, DotoBackdrop
└── screens/             ← 12 PNGs, 780×1688 (@2x of 390×844)
```

## Screens

| File | Screen | Notes |
|---|---|---|
| `01-home-pending.png` | Home · Pending | default state, 4 tasks, streak pill, category filters |
| `02-home-subtasks-expanded.png` | Home · checklist open | inline subtask expansion |
| `03-home-done.png` | Home · Done | completed styling, recurring tasks retained |
| `04-home-empty.png` | Home · empty | pending empty state |
| `05-add-empty.png` | Add task · empty | Save disabled, preview placeholder |
| `06-add-filled.png` | Add task · filled | live preview with all five new attributes |
| `07-insights.png` | Insights | streaks, 7-day bars, time by category, completion rate |
| `08-settings.png` | Settings | three toggles, category list |
| `09-home-dark.png` | Home · dark | |
| `10-insights-dark.png` | Insights · dark | chart colors on dark |
| `11-settings-dark.png` | Settings · dark | |
| `12-add-dark.png` | Add task · dark | field fills + focus ring on dark |

## Where to start

1. Read `DESIGN_SPEC.md` §1–3 (themes, type, geometry) — these are the whole visual system.
2. Drop `doto_theme.dart` into `lib/theme/` and wire `dotoTheme(dark: …)` with `AnimatedTheme` at 220ms.
3. Build `GlassSurface` once; every card, sheet, chip and the nav bar are that widget with different radius/padding.
4. Screens in build order: Home → Add → Insights → Settings.

## Fonts

Inter (400/500/600/700) and JetBrains Mono (400/700). Use `google_fonts`, or bundle both for offline builds. All numbers use tabular figures.

## Two things the static screens can't show

- **Motion** — durations and curves are in `DESIGN_SPEC.md` §5.
- **State logic** — validation, filtering, subtask progress, tab counts, all in §6.

The live prototype (`DoTo Redesign.dc.html` in the project) is the source of truth for both: every phone on that board is fully interactive.

## One open decision

Completing a **recurring** task currently just marks it done. Decide whether it should vanish until its next occurrence or stay with a “next: tomorrow” line — it changes the Done tab and the streak count.
