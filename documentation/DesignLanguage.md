# Design Language: "Don't Tap: Rogue Op"

This document defines the complete visual identity for the game. Every screen, component, and interaction should follow these rules to maintain the "Rogue Operating System" aesthetic.

---

## 1. Art Direction

- **Aesthetic:** Brutalist UI. Terminal console. Psychological testing facility.
- **Keywords:** Sterile, aggressive, deceptive, high-contrast, utilitarian.
- **Visual Rules:**
  - No rounded corners on system UI elements (menus, buttons, overlays). Everything should feel machine-built.
  - The only element that should feel "safe" or organic is the Focus Node itself.
  - Backgrounds are always near-black. Color is used sparingly and with purpose — to guide, warn, or deceive the player.

---

## 2. Color Palette

The color system relies on dark backgrounds to make neon elements physically jarring.

### Backgrounds & Surfaces
- **System Void (Primary Background):** #050505 (near black). Used everywhere as the base. Reduces OLED battery drain and maximizes contrast.
- **Terminal Surface (Overlays):** #121212 at 90% opacity. Used for pause menus and pop-up dialogs overlaying the game canvas.

### The "Safe" Palette (Player Actions)
- **Containment Cyan:** #00F0FF. Used exclusively for the Focus Node (idle state), the countdown timer (when safe), and primary action buttons like "Initiate Sequence."
- **Muted Teal (Pressed State):** #008B94. Visual feedback when the Focus Node is actively being held.

### The "Anomaly" Palette (Bait & Danger)
- **System Error Red:** #FF003C. Used for fake warnings, fake close buttons, anomaly borders, and the Game Over screen.
- **Hazard Yellow:** #FFF500. Used for deceptive "safe-looking" buttons or fake reward prompts designed to grab attention.

### Text & Lines
- **Primary Text:** #FFFFFF (pure white). For main instructions, headers, and the timer.
- **Dimmed Text:** #888888. For secondary labels, privacy policy text, and minor UI copy.
- **Gridlines (optional):** #1A1A1A. A very faint geometric background grid to subtly reinforce the "OS" feel without distracting from gameplay.

---

## 3. Typography

### Font: Space Mono (bundled locally)

The font files are already in `assets/font/`. They must be registered in `pubspec.yaml` as a custom font family — do NOT use the `google_fonts` package.

**Why Space Mono:** It is a geometric monospace typeface that captures the terminal/coding aesthetic. It has excellent legibility on high-density mobile displays, and its fixed-width characters make the countdown timer look precise and rigid.

### Type Scale

| Role | Size | Weight | Color | Notes |
|---|---|---|---|---|
| Countdown Timer | 64sp | Bold | Containment Cyan | Must use tabular figures so numbers don't shift horizontally as they tick down |
| Screen Headers | 32sp | Bold | White | Used for "The Terminal", "Containment Breach", etc. |
| Buttons & Prompts | 18sp | Bold | White, Cyan, or Red (contextual) | Always uppercase |
| Body Text | 14sp | Regular | Dimmed Text (#888888) | Line height 1.5. Used in Operator Manual, Privacy Policy |

---

## 4. Spacing, Layout & Responsiveness

### The 8pt Grid
All padding, margins, and component sizing should be multiples of 8 (8, 16, 24, 32, 48, 64). This keeps spacing consistent across every screen.

### Touch Targets
- **Minimum tappable size:** 48x48 dp for any interactive element (pause button, menu buttons). This is a Google Play accessibility requirement.
- **Focus Node size:** Minimum 120x120 dp. It must be large enough to hold a thumb on comfortably without the finger obscuring the surrounding area.

### Responsive Rules
- **Safe Areas:** All Flutter UI layers must be wrapped in SafeArea to avoid notches and system gesture bars.
- **Focus Node Position:** Centered horizontally, placed in the lower third of the screen. Do not hardcode pixel positions — use relative positioning based on screen size. The lower-third placement is ergonomically optimal for one-handed play.
- **Anomaly Spawn Bounds:** Define a spawn rectangle that is the full screen minus the safe area insets minus 32dp padding on each edge. This ensures no anomaly spawns half-off-screen or hidden under the system bar. Also exclude the Focus Node's bounding area plus a small buffer so nothing spawns directly under the player's thumb.

---

## 5. Core UI Components

### The Focus Node (Flame Component)
- **Idle:** A crisp, hollow geometric shape (circle or hexagon) rendered in Containment Cyan with a visible border.
- **Held:** Fills with solid Muted Teal and scales down slightly (roughly 90% scale). Should feel like pressing a physical fingerprint scanner.
- **Not Held:** Returns to idle appearance.

### Anomalies / Bait (Flame Components)
- **Appearance:** Designed to mimic real UI elements. Sharp rectangular boxes with thick 2px borders, filled or outlined in System Error Red or Hazard Yellow.
- **Deceptive variants:** Some anomalies should be styled to look like the Pause button, or like a native OS "Low Battery" dialog, or like a "You Won!" banner.
- **Motion:** Anomalies snap onto the screen or slide in with harsh, linear movement. No soft bouncing or easing. Everything should feel mechanical and abrupt.

### System Menus (Flutter Overlay Widgets)
- **Buttons:** Outlined sharp rectangles with a 2px border. No fill color by default.
- **Pressed State:** Button background flashes solid with the border color, text inverts to black.
- **Overlay Containers:** Pause and Game Over screens appear as sharp-edged dialog boxes with thick borders, floating over a semi-transparent dark background (use a simple dark color overlay at 85% opacity — avoid BackdropFilter blur for performance).

---

## 6. Motion & Feedback

### Haptics
- **Light pulse:** When the player first holds the Focus Node — confirms engagement.
- **Heavy jarring vibration:** The exact moment the player fails. Must feel physically impactful.

### Animations
- **Countdown Timer:** Ticks aggressively. No smooth easing — each second should feel like a discrete, hard step.
- **Anomaly Entry:** Anomalies appear instantly or slide in with harsh linear movement. No bounce, no ease-out.
- **Screen Shake on Failure:** A quick, short screen shake (roughly 0.2 seconds) on the Flame camera when a breach occurs. Makes the loss feel physical.

### Audio (see GDD for asset details)
- Background drone during active sequences (bg.m4a).
- Sharp spawn sound when anomalies appear (bait.wav).
- Harsh error sound on failure (error.flac), paired with the heavy haptic.
