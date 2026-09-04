// Rasterises the brand SVGs into the PNG sets Android and iOS still require.
//
//   npm install @resvg/resvg-js
//   node design/brand/render-png.mjs
//
// Run from the repo root. Overwrites the launcher PNGs in android/ and ios/.

import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const BRAND = resolve('design/brand');

function render(svgFile, width, outFile) {
  const svg = readFileSync(resolve(BRAND, svgFile), 'utf8');
  const png = new Resvg(svg, { fitTo: { mode: 'width', value: width } }).render().asPng();
  mkdirSync(dirname(resolve(outFile)), { recursive: true });
  writeFileSync(resolve(outFile), png);
  console.log(`${String(width).padStart(4)}px  ${outFile}`);
}

// --- Android: legacy launcher icons, used below API 26 (adaptive takes over above).
const ANDROID_DENSITIES = [
  ['mdpi', 48],
  ['hdpi', 72],
  ['xhdpi', 96],
  ['xxhdpi', 144],
  ['xxxhdpi', 192],
];
for (const [density, px] of ANDROID_DENSITIES) {
  render(
    'doto-app-icon-android-legacy.svg',
    px,
    `android/app/src/main/res/mipmap-${density}/ic_launcher.png`
  );
}

// --- iOS: every size named in AppIcon.appiconset/Contents.json.
const IOS_SIZES = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024];
const IOS_FILES = {
  20: 'Icon-App-20x20@1x.png',
  40: 'Icon-App-20x20@2x.png',
  60: 'Icon-App-20x20@3x.png',
  29: 'Icon-App-29x29@1x.png',
  58: 'Icon-App-29x29@2x.png',
  87: 'Icon-App-29x29@3x.png',
  80: 'Icon-App-40x40@2x.png',
  120: 'Icon-App-60x60@2x.png',
  180: 'Icon-App-60x60@3x.png',
  76: 'Icon-App-76x76@1x.png',
  152: 'Icon-App-76x76@2x.png',
  167: 'Icon-App-83.5x83.5@2x.png',
  1024: 'Icon-App-1024x1024@1x.png',
};
for (const px of IOS_SIZES) {
  render(
    'doto-app-icon-ios-light.svg',
    px,
    `ios/Runner/Assets.xcassets/AppIcon.appiconset/${IOS_FILES[px]}`
  );
}

// --- iOS 18 dark appearance slot.
render(
  'doto-app-icon-ios-dark.svg',
  1024,
  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024-dark@1x.png'
);

// Contents.json lists Icon-App-40x40@1x.png and Icon-App-40x40@3x.png as well;
// they are byte-identical to the 40px and 120px renders above.
render('doto-app-icon-ios-light.svg', 40, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png');
render('doto-app-icon-ios-light.svg', 120, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png');
