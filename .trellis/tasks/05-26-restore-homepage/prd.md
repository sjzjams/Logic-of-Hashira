# PRD: Restore Prototype Home Screen to Flutter App

## Background
The prototype folder `D:\Logic-of-Hashira\prototype\个人健身成长记录app` contains a set of static HTML files including `index.html`. This page showcases a specific design:
- Hand-drawn styling with radial background gradients (radial-gradient(circle at 18% 10%, rgba(122, 105, 255, .12), transparent 28%), radial-gradient(circle at 84% 86%, rgba(77, 60, 255, .10), transparent 30%), #f4f3f9).
- A custom category row ("Daily habits") with Chinese labels: "力量" (Strength), "有氧" (Cardio), "睡眠" (Sleep), "营养" (Nutrition), "心态" (Mindset), "恢复" (Recovery).
- Heart icon for 有氧 (Cardio) and leaf icon for 恢复 (Recovery).
- A greeting "早上好！, Sjzjams" and "Your future is in progress".
- A body sprite image in the center (`home-body-cutout.png` or a section of `spritesheet.png`) inside the hero card.

Our goal is to accurately port these elements to the Flutter home screen (`HomeScreen` in `lib/features/home/home_screen.dart`).

## Requirements

### 1. Project Configuration & Assets
- Create an `assets/images/` directory.
- Copy `spritesheet.png` and `home-body-cutout.png` from the prototype's assets to the new project assets.
- Register these assets in `pubspec.yaml`.

### 2. Styling and Colors
- Update the background of the app's `HomeScreen` (or overall shell if needed) to render the double radial gradient layout mimicking the CSS from the prototype:
  - Gradient 1: Circle at top-left (18% width, 10% height) with light purple accent (rgba(122, 105, 255, .12)).
  - Gradient 2: Circle at bottom-right (84% width, 86% height) with blue-soft accent (rgba(77, 60, 255, .10)).
  - Background color base: `#f4f3f9`.

### 3. Categories & Navigation
- The horizontal selector in `HomeScreen` must use Chinese text: `"力量"`, `"有氧"`, `"睡眠"`, `"营养"`, `"心态"`, `"恢复"`.
- Keep navigation logic intact (navigating to tabs or pushing screens).
- Update icons for "有氧" and "恢复" to draw the heart/leaf SVG paths as defined in the prototype.

### 4. Text Contents
- Update the greeting text to:
  - Header: `"早上好！, Sjzjams"`
  - Subtitle: `"Your future is in progress"`

### 5. Hero Card Sprite Integration
- Replace `ChestPortraitPainter` with the `home-body-cutout.png` image asset (or a clipped section from `spritesheet.png` matching the `-617px -24px` offset and `826px 1372px` background size with 170x345 dimensions). Since `home-body-cutout.png` is already extracted, we can directly use it.
- Keep the `HandDrawnCard` wrapping it, maintaining the card borders and action buttons.
