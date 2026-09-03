# DoTo — Spatial Glass · Flutter handoff spec

Design target: iPhone 390 × 844 pt (@2x screenshots in `screens/`).
Everything below is measured from the live prototype — values are logical pixels, 1 CSS px = 1 Flutter logical pixel.

---

## 1. Themes

The app has exactly two themes. Every surface is derived from the same eight roles, so one `ThemeExtension` covers both.

| Role | Light | Dark |
|---|---|---|
| Backdrop gradient | `#F7FAFC` 0% → `#E6EEF5` 52% → `#EDF3F7` 100%, 160° | `#0B1219` → `#132836` → `#0F1D28`, 160° |
| Foreground text | `#0A2543` | `#F2F7FB` |
| Muted text | `#0A2543` @ 66% | `#F2F7FB` @ 68% |
| Glass (cards, nav, sheets) | `#FFFFFF` @ 46% | `#FFFFFF` @ 9% |
| Glass secondary (empty state) | `#FFFFFF` @ 30% | `#FFFFFF` @ 6% |
| Edge (1px border) | `#FFFFFF` @ 60% | `#FFFFFF` @ 16% |
| Field (inputs, chips) | `#FFFFFF` @ 60% | `#FFFFFF` @ 8% |
| Accent / on-accent | `#004081` / `#FFFFFF` | `#00A9DC` / `#0B1219` |
| Selected pill (tab, nav item) | `#FFFFFF` bg, `#004081` text | `#FFFFFF` @ 92% bg, `#0B1219` text |

Blur on every glass surface: **CSS 20px ⇒ `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`**. Nav and Add-preview use 22px ⇒ sigma 11. Empty state 18px ⇒ sigma 9.

### Ambient light blobs (both themes)
Two non-interactive radial circles behind content, `IgnorePointer`:
- 260×260 at `top:-70, right:-60` — white @55% → transparent, center 30%/30%
- 240×240 at `bottom:120, left:-90` — `#00A9DC` @14% → transparent, center 60%/40%

### Semantic colors (theme-independent)
| Token | Hex | Use |
|---|---|---|
| Priority High | `#C25E3D` | 6px dot only |
| Priority Medium | `#F5C842` | 6px dot only |
| Priority Low | `#57A11F` | 6px dot only |
| Category · Work | `#004081` | 7px dot |
| Category · Personal | `#00A9DC` | 7px dot |
| Category · Health | `#57A11F` | 7px dot |
| Category · Home | `#F5C842` | 7px dot |
| Success / streak | `#57A11F` | streak number, completed subtask bar, hero chart bar |
| Destructive | `#C25E3D` | delete hover/press |

Rule from the brand system: **one accent per surface**. Priority and category colors are data marks (dots, bars) — never fills, never CTAs.

---

## 2. Typography

Two families: **Inter** (all UI) and **JetBrains Mono** (all numbers, times, durations, counters). Weights 400 / 500 / 600 / 700 only.

| Style | Family | Size | Weight | Tracking | Line height |
|---|---|---|---|---|---|
| Screen title (`Your day, in layers`) | Inter | 30 | 600 | −0.03em | 1.06 |
| Section title (Insights / Settings) | Inter | 26 | 600 | −0.028em | 1.15 |
| Screen title, Add | Inter | 20 | 600 | −0.025em | 1.2 |
| Card title | Inter | 16 | 600 | −0.015em | 1.35 |
| Card / setting subtitle | Inter | 13 | 400 | 0 | 1.5 |
| Setting row title | Inter | 15.5 | 600 | −0.015em | 1.3 |
| Card panel heading (Insights) | Inter | 14.5 | 600 | −0.015em | 1.3 |
| Eyebrow (`2 SEPTEMBER`) | Inter | 11 | 600 | 0.08em, UPPER | 1.2 |
| Field label (`TITLE *`) | Inter | 10 | 700 | 0.10em, UPPER | 1.2 |
| Category label on card | Inter | 10.5 | 700 | 0.07em, UPPER | 1.2 |
| Priority chip | Inter | 10.5 | 700 | 0.06em, UPPER | 1.2 |
| Tab / nav label | Inter | 12.5–13.5 | 600 | 0 | 1.2 |
| Meta chip (time, duration) | JetBrains Mono | 10.5 | 400 | 0 | 1.2 |
| Subtask counter, small stats | JetBrains Mono | 10.5–11.5 | 400 | 0 | 1.2 |
| Stat number | JetBrains Mono | 34 | 700 | −0.02em | 1.0 |
| Completion rate | JetBrains Mono | 26 | 700 | 0 | 1.0 |

All numeric styles use tabular figures: `FontFeature.tabularFigures()`.

---

## 3. Geometry

**Radii** — device 44 · card 26 · sheet / preview / chart panel 28 · empty state 32 · input 18 · subtask row & add-button 16 · subtask checkbox 5–6 · everything else pill (999).

**Borders** — 1px edge on every glass surface; 1.5px on checkboxes.

**Shadows**
- Card: `0 10 28 rgba(0,64,129,0.09)`
- Nav bar: `0 12 30 rgba(0,64,129,0.14)`
- Add preview sheet: `0 14 34 rgba(0,64,129,0.12)`
- FAB: `0 14 32 rgba(0,64,129,0.32)`
- Selected tab pill: `0 2 8 rgba(0,64,129,0.10)`
- Save button: `0 12 28 rgba(0,64,129,0.20)`
- Toggle knob: `0 2 8 rgba(0,0,0,0.20)`

**Spacing**
- Screen horizontal padding: **24**
- Status bar row: 16 top, 30 horizontal
- Card internal padding: 17 (home) / 18–20 (panels)
- Gap between cards: 13 · between panels: 12 · between form fields: 18
- Bottom nav: inset left/right 20, `bottom: 30`, height 62, inner padding 6
- FAB: 60×60, `right: 24, bottom: 104`
- Scroll bottom padding — Home **190**, Add **124**, Insights/Settings **120** (must clear the floating nav; this was a bug once)

---

## 4. Components

### 4.1 Status bar
Static mock: `9:41` left (12/600), signal + battery glyphs right at 80% opacity. Replace with the real system bar in Flutter.

### 4.2 Home header
Left: eyebrow date + two-line screen title. Right: **streak pill** — glass pill, 8/12 padding, leaf glyph in `#57A11F`, mono 12/700 count, `DAY` label 10/600 uppercase at 60%.

### 4.3 Category filter row
Horizontally scrollable, gap 8, no scrollbar. Chip: 8×13 padding, pill, 1px edge, glass fill, 7px dot + 12.5/600 label. Selected → accent fill, on-accent text, accent border. First chip is `All` (dot uses foreground color).

### 4.4 Tab switcher (Pending / Done)
Glass pill container, 5px padding, two equal children. Selected child: white pill + `#004081` text + small shadow. Label format `Pending · 3`.

### 4.5 Task card
Glass card, radius 26, padding 17. Layout top-to-bottom inside the right column:
1. **Meta line** — 7px category dot, category label, optional repeat glyph + cadence (loop icon 11px, 10.5/600, 62% opacity)
2. **Title** — 16/600, 6px above; when done: `lineThrough` + opacity 0.5
3. **Description** — 13/1.5 at 66%, optional
4. **Subtask row** (only if subtasks exist) — 5px progress track (field color) with a fill in accent, or `#57A11F` when complete; mono `2/3` counter; chevron rotating 0→180° over 200ms
5. **Expanded checklist** (when open) — column, gap 9, each row: 17px square box (radius 6, 1.5px border, accent fill when checked) + 13.5 label with strike-through at 50% when done
6. **Chip row** — gap 7, wraps: due chip (clock glyph + `Wed 2 Sep · 16:30`), duration chip (bars glyph + `2h`), priority chip (6px dot + label)

Left column: 26px round checkbox, 1.5px edge border; when checked → accent fill, on-accent tick. Top-right: 26px delete button, 40% opacity, hover/press → `#C25E3D` on a 14% red wash.

### 4.6 Empty state
Radius 32, secondary glass, padding 36/26, centered: 52px round field-colored circle with a 22px tick, 18/600 title, 13/1.5 body at 68%.
- Pending: “Nothing floating” / “This layer is clear. Tap + to add a task.”
- Done: “Nothing done yet” / “Completed tasks settle here.”

### 4.7 FAB
60px circle, accent fill, 1px edge, plus glyph 22px stroke 2.2. Press: lift 3px + scale 1.03 over 200ms.

### 4.8 Bottom nav
Floating glass pill, three equal items: **Tasks / Insights / Settings** (list, bar-chart, gear glyphs at 17px). Active item gets the white pill treatment; inactive uses muted text. Always visible on all four screens.

### 4.9 Add Task screen
Back button (38px glass circle) + title. Then, in order:
1. **Live preview sheet** — radius 28, glass, padding 18. Renders exactly the card body above, with an inert unchecked circle. Title falls back to “Your task title” at 45% opacity. Everything updates on each keystroke/tap.
2. `TITLE *` — text field, radius 18, field fill, 14/16 padding, focus ring `0 0 0 3px rgba(0,169,220,0.26)`
3. `DESCRIPTION` — 2-row text area, same styling
4. `CATEGORY` — four dot chips, single select
5. `DUE` — date field (flex) + time field (116 wide)
6. `DURATION` — presets `15m 30m 45m 1h 2h`, mono labels, single select; current value echoed at the right of the label row
7. `REPEAT` — `None / Daily / Weekly / Monthly`, single select
8. `SUBTASKS` — existing rows (16px radius, inert box, title, × remove) then an input + 46px add button; Enter also commits
9. `PRIORITY` — High / Medium / Low, single select
10. **Save task** — 54px pill, accent fill; disabled state = field fill + muted text + 75% opacity + `not-allowed`
11. Hint line below, 11.5 at 62%: “Saves to Pending” / “A title is required”

Selected-chip pattern is identical everywhere: accent fill + accent border + on-accent text; unselected: field fill + edge border + muted text.

### 4.10 Insights screen
- Eyebrow `LAST 7 DAYS` + 26/600 headline stating the insight
- Two stat cards side by side (gap 12): **Streak** (leaf glyph, number in `#57A11F`) and **Best streak**
- **Bar chart panel** — title states the finding (“Monday was your strongest day”). 7 bars, height = `count / max × 88`, radius `8 8 4 4`, accent fill with the max day in `#57A11F`. Count above, day label below, both mono 10 at 60%. Zero baseline, no gridlines, no legend.
- **Time by category** — four rows: dot + name + mono duration, 6px track with a fill in the category color, width = `mins / maxMins`
- **Completion rate** — label + subline + mono 26 percentage

### 4.11 Settings screen
Two grouped glass sheets, hairline dividers (`edge` color, 1px) between rows, 19/18 padding per row.
Sheet 1 — **Dark mode**, **Streak reminders**, **Roll over recurring tasks**. Each row: 15.5/600 title + 12.5 subtitle at 66% + 54×32 toggle.
Sheet 2 — **Categories** (count + chip list) and **Completed tasks** (count).
Footer: mono 10.5 `DOTO v2.0 · SPATIAL` at 55%.

**Toggle spec** — track 54×32, pill, 1px edge, 3px padding; knob 24px circle, accent fill, travel 22px, 220ms ease. Off track = field/white 50% (light) or white 14% (dark); on track = accent @ 18–30%.

---

## 5. Motion

Calm and short — no bounce, no springs.

| Interaction | Duration | Curve |
|---|---|---|
| Card / screen entry (`fade + translateY 10 + scale 0.99`) | 260ms | ease |
| Screen transition | 240ms | ease |
| Chip / tab / button state change | 170–180ms | ease |
| Checkbox fill | 180ms | ease |
| Toggle knob | 220ms | ease |
| Subtask progress bar width | 260ms | ease |
| Chart bar height | 300ms | ease |
| Chevron rotation | 200ms | ease |
| Theme change | 200–260ms | ease |
| FAB press lift | 200ms | ease |

---

## 6. Data model

```dart
enum Priority { high, medium, low }
enum Repeat { none, daily, weekly, monthly }
enum Category { work, personal, health, home }

class Subtask { int id; String title; bool done; }

class Task {
  int id;
  String title;          // required, trimmed, non-empty
  String description;    // optional
  DateTime due;          // date + time
  int durationMinutes;   // 15 | 30 | 45 | 60 | 120 (presets)
  Priority priority;     // default medium
  Category category;     // default work
  Repeat repeat;         // default none
  bool done;
  List<Subtask> subtasks;
}
```

**Formatting**
- Due chip: `EEE d MMM · HH:mm` → `Wed 2 Sep · 16:30`
- Duration: `<60 → "45m"`, else `"2h"` / `"1h 30m"`
- Subtask counter: `done/total`

**Behaviours**
- Save is blocked while `title.trim()` is empty.
- Saving prepends to the list, returns to Home, resets the tab to Pending and the category filter to All.
- Toggling a task moves it between Pending and Done; counts in the tab labels update live.
- Toggling a subtask updates the parent's progress bar; at 100% the bar turns `#57A11F` (the parent does **not** auto-complete).
- The category filter applies to both tabs and to the counts.
- Delete removes immediately (no confirm in the prototype — add an undo snackbar if you want one in production).
- Only one card's checklist is expanded at a time.

**Open question for you:** when a recurring task is completed, should it disappear until its next occurrence, or stay visible with a “next: tomorrow” line? The prototype currently just marks it done.

---

## 7. Flutter notes

- Glass = `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` + a `Container` with the white-alpha fill and a 1px `Border.all(color: edge)`. Blur is expensive: keep the blurred subtree small (per card), and consider a static translucent fill for long lists on low-end Android.
- The backdrop gradient belongs to the `Scaffold` body, **not** to each card — the cards must sample it.
- Fonts: `google_fonts` → `GoogleFonts.inter` and `GoogleFonts.jetBrainsMono`, or bundle Inter variable + JetBrains Mono for offline builds.
- Put the eight theme roles in a `ThemeExtension<DotoColors>` and switch with `AnimatedTheme` (200ms) so the dark-mode flip animates like the prototype.
- Bottom nav is a floating `Positioned` pill, not a `BottomNavigationBar` — the content scrolls behind it. Keep the scroll padding values in §3 or the Save button will hide behind the bar.
- Tap targets: checkboxes are drawn at 26px but should carry a 44px hit area; same for the 26px delete button.
- Chart is simple enough to draw with `Container` heights in a `Row` — no chart package needed.

## 8. Files

- `screens/` — 12 PNGs at 780×1688 (@2x)
- `doto_theme.dart` — drop-in tokens + `ThemeExtension` + text styles
- The interactive prototype lives in the project as `DoTo Redesign.dc.html`; every phone on that board is live, so use it for motion and state questions this document can't answer.
