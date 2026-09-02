# Implementation Plan: DoTo — Spatial Glass Redesign (V2 — Hardened)

## 1. Overview & Objectives
Transform the existing DoTo Flutter app to match the **Spatial Glass** design specification with pixel-perfect visual fidelity across all 12 reference screens in `handoff/screens/`, strictly adhering to `handoff/DESIGN_SPEC.md` and `handoff/doto_theme.dart`.

This upgraded plan incorporates findings from the **Adversary Architecture & Design Review**, resolving rendering performance risks, data model migrations, layout clipping, and interaction nuances.

---

## 2. Design System & Theme Foundations

### 2.1 Color Palette & Theme Roles (`DotoColors`)
- Integrate `DotoColors` ThemeExtension supporting both **Light** and **Dark** modes:
  - **Light Mode**:
    - Backdrop: `[#F7FAFC, #E6EEF5, #EDF3F7]` (160° linear gradient)
    - FG text: `#0A2543`, Muted text: `rgba(10, 37, 67, 0.66)`
    - Glass surface: `rgba(255, 255, 255, 0.46)`
    - Glass secondary: `rgba(255, 255, 255, 0.30)`
    - Edge border: `rgba(255, 255, 255, 0.60)`
    - Field fill: `rgba(255, 255, 255, 0.60)`
    - Accent / On-accent: `#004081` / `#FFFFFF`
    - Pill: `#FFFFFF` bg, `#004081` text
    - Priority chip: `rgba(255, 255, 255, 0.55)`
  - **Dark Mode**:
    - Backdrop: `[#0B1219, #132836, #0F1D28]` (160° linear gradient)
    - FG text: `#F2F7FB`, Muted text: `rgba(242, 247, 251, 0.68)`
    - Glass surface: `rgba(255, 255, 255, 0.09)`
    - Glass secondary: `rgba(255, 255, 255, 0.06)`
    - Edge border: `rgba(255, 255, 255, 0.16)`
    - Field fill: `rgba(255, 255, 255, 0.08)`
    - Accent / On-accent: `#00A9DC` / `#0B1219`
    - Pill: `rgba(255, 255, 255, 0.92)` bg, `#0B1219` text
    - Priority chip: `rgba(255, 255, 255, 0.10)`
- **Semantic Marks (Theme-Independent)**:
  - Priority High: `#C25E3D`, Medium: `#F5C842`, Low: `#57A11F` (6px dots only)
  - Category Work: `#004081`, Personal: `#00A9DC`, Health: `#57A11F`, Home: `#F5C842` (7px dots)
  - Success / Streak: `#57A11F`
  - Destructive: `#C25E3D`

### 2.2 Glassmorphism & Ambient Glow (`DotoBackdrop` & `GlassSurface`)
- `DotoBackdrop`: 160° multi-stop gradient background + two non-interactive ambient radial glow blobs:
  - Top-right blob: 260×260 at `top: -70, right: -60` (Center: `Alignment(-0.4, -0.4)`, `Color(0x8CFFFFFF)` → transparent)
  - Bottom-left blob: 240×240 at `bottom: 120, left: -90` (Center: `Alignment(0.2, -0.2)`, `Color(0x2400A9DC)` → transparent)
- `GlassSurface`:
  - Wrapped in `RepaintBoundary` for render tree isolation and GPU performance.
  - Granular blur sigmas per component:
    - Standard Cards & Sheets: `sigma: 10.0` (CSS 20px)
    - Floating Bottom Nav & Live Preview Sheet: `sigma: 11.0` (CSS 22px)
    - Empty State Card: `sigma: 9.0` (CSS 18px)
  - 1px edge border (`c.edge`), customizable radius, padding, and specific box shadows (`DotoShadow`).

### 2.3 Typography & Fonts
- Dependencies: `google_fonts` (`Inter` for UI text, `JetBrains Mono` with `FontFeature.tabularFigures()` for all numbers, times, durations, and counters).
- Exact text styles matching `DESIGN_SPEC.md` §2.

---

## 3. Architecture & Core Layout Shell

### 3.1 Floating Bottom Navigation (`MainWrapper`)
- Structure `MainWrapper` with a `Stack` containing the active tab screen and a floating navigation pill.
- Positioned: `bottom: 30`, `left: 20`, `right: 20`, `height: 62`.
- Active item uses animated white pill background (`DotoColors.pill`), inactive items use muted text color (`DotoColors.muted`).
- Three tabs: **Tasks** (list icon), **Insights** (bar chart icon), **Settings** (gear/sun icon).
- Dynamic theme switching powered by `AnimatedTheme(duration: Duration(milliseconds: 220))`.

### 3.2 Viewport & Scroll Inset Hierarchy
Every scroll view must enforce bottom padding to allow content to scroll completely past floating elements:
- **Home Screen**: `190px` (clears floating nav at 30 + 62 and FAB at 104 + 60).
- **Add Task Screen**: `124px`.
- **Insights & Settings Screens**: `120px`.

### 3.3 Reusable Interactive Components
- **Toggle Switch**: Custom 54×32 pill with 1px border, 3px padding, 24px circular knob with 22px travel, animated with 220ms ease curve.
- **Filter Chips**: Pill shape, 8×13 padding, 7px category dot + label. Active state applies accent fill + on-accent text.
- **Priority Chips**: Pill shape with 6px semantic color dot + uppercase priority label.
- **Custom Checkbox**: 26px round checkbox with 1.5px border and a 44px hit-test area (`HitTestBehavior.opaque`).
- **Subtask Checkbox**: 17px square checkbox (radius 6px, 1.5px border, accent fill when checked).
- **Delete Button**: 26px square/circle with 44px hit-test area, 40% idle opacity, hover/press red wash (`#C25E3D` with 14% red background).
- **Floating Action Button (FAB)**: 60×60 circle, accent fill, plus icon (22px stroke 2.2), positioned `right: 24, bottom: 104`, with 200ms scale (1.03) and 3px lift on tap.

---

## 4. Screen-by-Screen Specifications

### 4.1 Home Screen (`HomeScreen`)
- **Header**:
  - Eyebrow with uppercase formatted date (e.g. `2 SEPTEMBER`).
  - Screen title: `Your day, in layers` (30pt, w600).
  - Streak pill: Leaf glyph in `#57A11F` + mono count + `DAY` label in 60% opacity.
- **Category Filter Carousel**:
  - Horizontal list of categories (`All`, `Work`, `Personal`, `Health`, `Home`).
  - Filters both task lists and dynamically updates the badge counts on the Pending / Done tab switcher.
- **Pending / Done Tab Switcher**:
  - Pill container with two equal options formatted as `Pending · X` and `Done · Y`.
- **Task List & Interactive Task Cards**:
  - Glass card (`radius: 26`, `padding: 17`, gap `13`).
  - Meta line: 7px category dot + category name + optional repeat cadence icon (`🔁 Daily/Weekly/Monthly`).
  - Title with conditional strikethrough + 0.5 opacity when marked Done.
  - Optional description (13pt, w400, 66% opacity).
  - Subtask progress bar: 5px track with accent fill, turning `#57A11F` at 100%, mono `done/total` count, and 180° animated rotating chevron.
  - Expandable Subtasks Checklist: Single-card expansion mode (only one card expanded at a time), checkboxes (radius 6), line-through text.
  - Chip row: Due timestamp (`EEE d MMM · HH:mm`), duration (`45m`, `2h`), priority dot + name.
  - Top-right delete button (26px with hover/press red wash).
- **Empty State**:
  - Glass card (`radius: 32`, secondary glass fill, padding 36/26, `sigma: 9`).
  - 52px circular icon container with 22px checkmark.
  - Contextual copy: "Nothing floating" (Pending) vs "Nothing done yet" (Done).

### 4.2 Add Task Screen (`AddTaskScreen`)
- **Header**: Back button (`38px` glass circle) + screen title `Add task`.
- **Live Preview Sheet**:
  - Glass card (`radius: 28`, `padding: 18`, `sigma: 11`) rendered at the top.
  - Live reactive preview updating instantly on every keystroke or option change.
  - Default placeholder: "Your task title" at 45% opacity.
- **Form Fields (Gap 18)**:
  1. `TITLE *`: Text field (`radius: 18`, field fill, focus ring `rgba(0,169,220,0.26)`).
  2. `DESCRIPTION`: Multi-line text field.
  3. `CATEGORY`: 4 single-select chips (`Work`, `Personal`, `Health`, `Home`).
  4. `DUE`: Date picker + Time picker fields.
  5. `DURATION`: Preset chips (`15m`, `30m`, `45m`, `1h`, `2h`).
  6. `REPEAT`: Cadence options (`None`, `Daily`, `Weekly`, `Monthly`).
  7. `SUBTASKS`: Inline subtask list with remove action + input field with `+` button.
  8. `PRIORITY`: Single-select chips (`High`, `Medium`, `Low`).
- **Save Task Button & Action**:
  - 54px pill with accent fill.
  - Disabled state: field fill + muted text + 75% opacity when `title.trim()` is empty.
  - Helper note below button: "Saves to Pending" / "A title is required".
  - On save: Prepend task to list, navigate back to Home, reset tab to Pending (`0`), and reset Category filter to `All`.

### 4.3 Insights Screen (`InsightsScreen`)
- **Header**: Eyebrow `LAST 7 DAYS` + dynamic insight headline (e.g. "You closed 25 tasks and kept a 12-day streak").
- **Stat Cards (Side-by-side, gap 12)**:
  - **Streak**: Leaf glyph, count in `#57A11F`, subline `days in a row`.
  - **Best streak**: Count in `#0A2543` (light) / `#F2F7FB` (dark), subline `set in August`.
- **Bar Chart Panel**:
  - Glass panel with dynamic finding headline (e.g. "Monday was your strongest day").
  - 7 custom animated bars (`height = maxCount > 0 ? (count / maxCount * 88) : 0`, radius `8 8 4 4`), max day bar colored in `#57A11F`, other days in accent.
  - Mono count above bars, uppercase day label below bars. Zero baseline rendered cleanly without clipping.
- **Time by Category Breakdown**:
  - Category rows with dot + name + duration formatted in mono.
  - 6px progress track with fill colored in category color (`width = maxMins > 0 ? (mins / maxMins) : 0.0`).
- **Completion Rate Panel**:
  - Heading + subline + large mono 26pt percentage display (guarded against division by zero).

### 4.4 Settings Screen (`SettingsScreen`)
- **Header**: Eyebrow `PREFERENCES` + screen title `Settings`.
- **Sheet 1 (Toggles)**:
  - Grouped glass sheet with hairline dividers (`edge` color).
  - Row 1: **Dark mode** ("Off — daylight glass" / "On — deep slate glass") with custom toggle.
  - Row 2: **Streak reminders** ("On — nudge me at 20:00") with custom toggle.
  - Row 3: **Roll over recurring tasks** ("On — missed repeats move to today") with custom toggle.
- **Sheet 2 (Overview)**:
  - Grouped glass sheet.
  - Row 1: **Categories** with count badge (4) and non-interactive chip pills.
  - Row 2: **Completed tasks** with total completed count badge.
- **Footer**:
  - Monospace text: `DOTO v2.0 · SPATIAL` at 55% opacity.

---

## 5. State Management & Data Lifecycle

### 5.1 Recurring Task Lifecycle Resolution
1. When a recurring task is toggled to Done:
   - The current task is marked `isCompleted = true`, stamped with `completedAt = DateTime.now()`, and remains in the **Done** tab.
   - A new recurring clone instance is created with the next scheduled date (Daily $+1\text{d}$, Weekly $+7\text{d}$, Monthly $+1\text{mo}$) and added to **Pending**.
   - The original completed task stores `nextRecurrenceId = clone.id`.
2. If the user unchecks the completed task:
   - The spawned clone task is deleted using `nextRecurrenceId`.
   - The original task is reverted to `isCompleted = false` and moved back to Pending.
3. This preserves accurate 7-day stats and streaks while keeping upcoming repeats seamless.

### 5.2 Subtasks Progress vs Task Completion
- Toggling subtasks updates the parent task's progress bar (turns `#57A11F` at 100%).
- The parent task does **not** auto-complete when all subtasks are checked.
- Checking the parent task checkbox marks all child subtasks completed; unchecking it resets them.

### 5.3 Single Accordion State
- `TaskProvider` tracks `expandedTaskId` (nullable string). Expanding a card automatically collapses any other open card.

---

## 6. Motion & Haptics Schedule

- **Haptic Feedback**:
  - Task toggle: `HapticFeedback.mediumImpact()`
  - Subtask toggle: `HapticFeedback.selectionClick()`
  - Filter chip / tab switch: `HapticFeedback.selectionClick()`
  - FAB tap: `HapticFeedback.lightImpact()`
- **Motion (`DotoMotion`)**:
  - Screen entry / list reorder: `260ms Curves.ease`
  - Screen transitions: `240ms Curves.ease`
  - Toggle knob travel: `220ms Curves.ease`
  - Subtask progress bar: `260ms Curves.ease`
  - Subtask chevron rotation: `200ms Curves.ease`
  - Theme change: `220ms AnimatedTheme`
  - FAB press lift: `200ms`

---

## 7. Execution Checklist & Phasing

1. **Phase 1: Dependencies & Theme Setup**
   - Add `google_fonts: ^6.2.1` to `pubspec.yaml`.
   - Setup `lib/theme/doto_theme.dart` and bind into `main.dart` with `AnimatedTheme`.
2. **Phase 2: Common Widgets & Navigation Shell**
   - Build `GlassSurface`, `DotoBackdrop`, custom `DotoToggle`, and floating bottom navigation in `MainWrapper`.
3. **Phase 3: Data Layer & Provider Alignment**
   - Implement category-filtered counts, safe stats math, recurring clone lifecycle, and accordion state in `TaskProvider`.
4. **Phase 4: Home Screen & Task Card**
   - Build header with date/streak pill, category filters, tab switcher, task cards with subtasks progress & expansion, and empty states.
5. **Phase 5: Add Task Screen**
   - Build real-time reactive live preview sheet and form controls with validation.
6. **Phase 6: Insights Screen**
   - Build 7-day bar chart, streaks cards, category duration bars, and completion rate.
7. **Phase 7: Settings Screen**
   - Build grouped glass sheets with custom toggles and category/completed counters.
8. **Phase 8: Visual QA & Analysis**
   - Run `flutter analyze` and verify every screen against the 12 handoff PNGs.
