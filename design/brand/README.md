# DoTo brand assets

This directory is the **master set**. The app now uses copies of these files —
see **Where each asset landed** — so edit here first, then re-copy and re-render.

## The mark — "Layered Check"

Three task cards stacked in depth, the front one struck through with the accent
check. Authored on a **120 grid**: three 76×76 tiles at radius 24, stepped 8px up
and to the right. Check stroke 8, round caps and joins, on the same geometry as
the 44px checkbox in `lib/widgets/doto_checkbox.dart`.

Colours come straight from `lib/theme/doto_theme.dart`:

| Role | Value |
|---|---|
| Front tile, light | `#00A9DC → #004081`, 160° (bottom-left to top-right) |
| Front tile, dark | `#5FD3F5 → #00A9DC` |
| Rear layers, light | `#004081` at 30% and 14% |
| Rear layers, dark | `#FFFFFF` at 20% and 10% |
| Check, light / dark | `#FFFFFF` / `#0B1219` |

Mark bounding box is `14,6 → 106,98` in the 120 grid (92×92), centre `60,52`.
Below ~24px the rear layers stop resolving and the front tile carries the mark
alone — that is expected, not a bug.

## Masters

| File | What it is |
|---|---|
| `doto-mark.svg` | Primary mark, transparent. The master everything else derives from. |
| `doto-mark-dark.svg` | Dark-surface variant (cyan tile, night-blue check). |
| `doto-mark-mono.svg` | Flat single colour. The check is real transparency, so it survives alpha-masking and tinting. |
| `doto-lockup.svg` | Horizontal mark + wordmark. Wordmark is **outlined** from `assets/fonts/Inter-SemiBold.ttf` (46px, −1.9 tracking, kerning applied) — renders anywhere, no font needed. |
| `doto-app-icon-android-foreground.svg` | 108dp adaptive-icon canvas, artwork at 68dp inside the 66dp safe zone. |
| `doto-app-icon-android-legacy.svg` | 108dp canvas, artwork at 89% — the pre-API-26 launcher PNG source. |
| `doto-app-icon-ios-light.svg` | 1024² iOS icon on the pale glass tile. |
| `doto-app-icon-ios-dark.svg` | 1024² iOS icon on the night tile, wired to the iOS 18 dark appearance slot. |
| `android/*.xml` | VectorDrawables, copied verbatim into `res/`. |
| `render-png.mjs` | Regenerates every PNG the platforms still demand. |

## Where each asset landed

**Android** (`android/app/src/main/res/`)

| Asset | Destination |
|---|---|
| `android/ic_notification.xml` | `drawable/ic_notification.xml` (replaced the generic Material checkbox) |
| `android/ic_launcher_foreground.xml` | `drawable/ic_launcher_foreground.xml` |
| `android/ic_launcher_monochrome.xml` | `drawable/ic_launcher_monochrome.xml` |
| `android/ic_launcher.xml` | `mipmap-anydpi-v26/ic_launcher.xml` (new dir; wins over the PNGs on API 26+) |
| rendered from `-legacy.svg` | `mipmap-{m,h,x,xx,xxx}dpi/ic_launcher.png` |

Also added: `drawable/ic_splash.xml` + `drawable-night/ic_splash.xml` (the launch
mark), `values/colors.xml` + `values-night/colors.xml` (`launch_bg`), and both
`launch_background.xml` layer-lists now paint `@color/launch_bg` with the mark
centred on top.

**iOS** — `ios/Runner/Assets.xcassets/AppIcon.appiconset/`, all 15 sizes rendered
from `doto-app-icon-ios-light.svg`.

**Dart** — `lib/services/notification_service.dart`: six `@mipmap/ic_launcher`
references became `@drawable/ic_notification`. A full-colour launcher icon in the
status bar is alpha-masked by Android into a white blob; the flat variant is the
only one that survives.

## Regenerating the PNGs

```bash
npm install @resvg/resvg-js     # prebuilt binary, no system libraries needed
node design/brand/render-png.mjs
```

Run from the repo root. `node_modules/` is not committed and is not in
`.gitignore` — delete it after rendering, or add an ignore rule.

## Platform notes

- **Android** takes the free-standing mark as-is: the adaptive foreground sits on
  a transparent background layer, so the wallpaper shows through the gaps between
  the layers. minSdk is 24, so the gradient VectorDrawables are safe everywhere,
  and adaptive icons cover API 26+.
- **iOS renders a transparent app icon black**, so the iOS set is the mark on a
  solid tile. That is a platform rule, not a design choice.
- **Notification icons** are alpha-masked and tinted by the system, which is why
  `ic_notification.xml` is flat with the check knocked out as transparency.

## Still open

- **The iOS dark icon is unverified.** `Icon-App-1024x1024-dark@1x.png` is
  rendered and registered in `Contents.json` as a `luminosity: dark` appearance
  on a `universal` / `platform: ios` entry — the shape Xcode 16 uses. It could
  not be compiled here (no Xcode on Windows), and appearance variants are
  normally authored in the single-size catalog format rather than alongside the
  classic all-sizes list this project uses. If Xcode rejects or ignores it,
  delete that one JSON object to revert; the proper fix is converting the whole
  set to single-size (one 1024 per appearance) with Xcode 16+.
- No tinted variant. iOS 18 also has a `luminosity: tinted` slot, which wants a
  grayscale master — say the word and it is a small addition.
