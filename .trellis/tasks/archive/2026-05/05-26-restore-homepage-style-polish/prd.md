# PRD: Strict 1:1 Homepage Style Polish

We will refine the `HomeScreen` in `lib/features/home/home_screen.dart` to strictly match the prototype's `index.html` style, layout, elements, and spacing.

## Requirements

### 1. Topbar Year Pill & Notification Icon
- **Year Pill**:
  - Background: White (`#FFFFFF`).
  - Border: `1px solid #e7e4f4`.
  - Border Radius: `15px`.
  - Text Color: `#4d3cff` (Pangolin, font-size 15px).
  - Arrow Icon: Custom SVG Arrow down drawing.
- **Notification Icon**:
  - A clean button containing the custom SVG Bell outline:
    `M8.2 17.4h7.6M10.2 19.4c.5.7 1.1 1 1.8 1s1.3-.3 1.8-1M7.8 16.7c.9-.7 1.1-1.8 1.1-3.5v-1.8a3.1 3.1 0 0 1 6.2 0v1.8c0 1.7.2 2.8 1.1 3.5`
  - Stroke: `#201381`.
  - Width/Height: 31px.
  - No default material icon, no red dot.

### 2. Daily Habits Grid Selector
- Instead of a horizontal scrolling ListView, it must be a **6-column grid row** (`Row` with `Expanded` items or `GridView` with no scroll) spanning the full width of the screen.
- **No white circle container or borders** around the category icons! The icons must be drawn directly on the wash background.
- SVG Icon style: Stroke width `1.65`, stroke color `#4d3cff`, fill `none`. Size: `30x30` px.
- Label: Below the icon, text color `#201381`, font size `10px`, line-height `1`.

### 3. Greeting Section
- Centered layout, margins matching CSS:
  - Header: `"早上好！, Sjzjams"` (font-size 23px, line-height 1.2, font-weight 500, color `#201381`).
  - Subtitle: `"Your future is in progress"` (font-size 12px, letter-spacing 1.5px, color `#5d5791`).

### 4. Center Body Image (Figure Wrap)
- The body image (`home-body-cutout.png`) must be placed **directly on the background**, without any card wrapper (`HandDrawnCard`).
- Add appropriate padding to match the prototype's centered flex layout.

### 5. Today's Focus Card
- Style the card manually:
  - Border: `1px solid #e7e4f4`.
  - Border Radius: `16px`.
  - Background: `#FFFFFF`.
  - Shadow: `BoxShadow(color: Color(0x0D201381), blurRadius: 28, offset: Offset(0, 10))`.
  - Layout: Left icon, middle texts, right "Start" button.
- **Focus Icon (Left)**:
  - Container size: 24x24 px, border `1.5px solid #7c6cff`, border-radius 8px.
  - Custom SVG inside: Document outline with lines:
    `M5 4.5h4.3l1.7 1.7v5.3H5V4.5Z` and `M7 8h2.8M7 10h2`.
- **Start Button (Right)**:
  - Height: 32px, min-width: 68px.
  - Border: `1px solid #bcb4ff`.
  - Border Radius: `13px`.
  - Background: Gradient from white to `#fbfaff`.
  - Text: `"Start"`, color `#4d3cff`, font-size 12px.
