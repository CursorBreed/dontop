# Implementation Plan: "Don't Tap: Rogue Op"

This is the complete, step-by-step build plan from an empty Flutter project to a shippable game. Each phase builds on the previous one. No code is included — this is a task specification for developers who know Flutter and Flame.

Reference the **GDD** for game mechanics and screen details, and the **Design Language** doc for all visual/audio/haptic specifications.

---

## Phase 1: Project Setup & Configuration

**Goal:** Get the project dependencies and asset pipeline ready so nothing blocks later phases.

### 1.1 Dependencies
Add the following packages to `pubspec.yaml`:
- **flame** — Core game engine (already added).
- **flame_audio** — Audio playback for background drone and sound effects (already added).
- **shared_preferences** — Local storage for the Restraint Index (highest level reached, total time endured) and user settings (audio/haptics toggles).

No other external packages are needed. Flutter's built-in `HapticFeedback` from `services.dart` handles all vibration needs. The Space Mono font is bundled locally so no Google Fonts package is required.

### 1.2 Font Registration
Register the Space Mono font family in `pubspec.yaml` under the `fonts` section. Declare the family name "SpaceMono" with entries for Regular, Bold, Italic, and BoldItalic weights pointing to the files in `assets/font/`.

### 1.3 Asset Registration
Ensure all three asset folders are declared in `pubspec.yaml`:
- `assets/images/` (logo.png, icon.png)
- `assets/audio/` (bg.m4a, bait.wav, error.flac)
- `assets/font/` (already covered by font registration, but the folder must exist)

### 1.4 Folder Structure
Organize the `lib/` directory as follows:
- `lib/main.dart` — App entry point. Sets up MaterialApp, routes, and the initial screen.
- `lib/game/` — Everything related to the Flame game engine.
  - `lib/game/protocol_game.dart` — The main FlameGame subclass that manages the game loop.
  - `lib/game/components/` — Individual Flame components (Focus Node, anomaly types, timer display).
  - `lib/game/managers/` — Game logic controllers (level configuration, anomaly spawning).
- `lib/screens/` — Flutter widget screens (splash, terminal/menu, settings, how-to-play, privacy policy, score display).
- `lib/overlays/` — Flutter widgets used as Flame overlays (pause menu, game over, level complete).
- `lib/theme/` — The design system constants (colors, text styles, spacing values).

Rename or remove the existing `lib/game/dont_tap_rogue_op_game.dart` file — the game class should be named `ProtocolGame` (matching the "Protocol: Restraint" theme) and live in `protocol_game.dart`.

---

## Phase 2: Design System & Theme

**Goal:** Build a single source of truth for all visual constants so every screen looks consistent.

### 2.1 Design System File
Create a file in `lib/theme/` that defines all the constants from the Design Language doc:
- **Colors:** System Void (#050505), Terminal Surface (#121212), Containment Cyan (#00F0FF), Muted Teal (#008B94), System Error Red (#FF003C), Hazard Yellow (#FFF500), Primary Text (#FFFFFF), Dimmed Text (#888888).
- **Text Styles:** Define a set of TextStyle constants using the registered SpaceMono font at the sizes specified in the Design Language doc (64sp timer, 32sp headers, 18sp buttons, 14sp body). The timer style must use tabular figures.
- **Spacing:** Constants for the 8pt grid values (8, 16, 24, 32, 48, 64).

### 2.2 App Theme
Create a ThemeData in `main.dart` that uses the System Void background color, white primary text color, and SpaceMono as the default font. This ensures even basic Flutter widgets inherit the correct look.

---

## Phase 3: Navigation & Screen Shells

**Goal:** Build all the screens as empty shells with working navigation between them, before adding any game logic.

### 3.1 Splash Screen (System Boot)
- A full-screen black page displaying the game logo (from `assets/images/logo.png`) and a simple loading indicator.
- On load, preload all audio assets using Flame Audio's cache.
- After preloading completes (or after a minimum 2-second delay, whichever is longer), automatically navigate to the Terminal.

### 3.2 Terminal (Main Menu)
- Black background. Game logo at the top. Five menu options listed vertically, styled as outlined rectangular buttons per the Design Language.
- Each button navigates to its respective screen:
  - "Initiate Sequence" → Gameplay screen
  - "Operator Manual" → How to Play screen
  - "System Calibration" → Settings screen
  - "Restraint Index" → Score/progression screen
  - "Data Silence Agreement" → Privacy Policy screen

### 3.3 Operator Manual (How to Play)
- A simple screen with three steps, each accompanied by a short text description:
  1. Hold the Focus Node.
  2. Ignore all System Anomalies.
  3. Survive the timer.
- A back button returns to the Terminal.

### 3.4 System Calibration (Settings)
- Two toggle switches: Sound Effects on/off, Haptic Feedback on/off.
- Read and write toggle states using shared_preferences.
- Default both to ON on first launch.
- A back button returns to the Terminal.

### 3.5 Restraint Index (Score Screen)
- Displays two values read from shared_preferences:
  - Highest Sequence Reached (level number).
  - Total Time Endured (formatted as minutes and seconds).
- If no data exists yet, show zeroes.
- A back button returns to the Terminal.

### 3.6 Data Silence Agreement (Privacy Policy)
- A scrollable text screen with a short statement: the game is fully offline, collects no personal data, and stores scores locally on the device only.
- A back button returns to the Terminal.

### 3.7 Gameplay Page
- This is the page that hosts the Flame GameWidget. For now, create it with a blank GameWidget and register the overlay keys that will be used later: "PauseMenu", "GameOver", "LevelComplete".
- A basic scaffold that passes the ProtocolGame instance to the GameWidget.

---

## Phase 4: Core Game Engine

**Goal:** Build the Flame game class and the fundamental gameplay mechanics — the Focus Node, the timer, and the win/lose logic.

### 4.1 The ProtocolGame Class
- Extends FlameGame.
- Tracks the current game state using an enum with values: active, suspended, breached, survived.
- Holds a reference to the current level number (starting at 1).
- On load, places the Focus Node component and the timer display component on the canvas.
- The game starts in a "waiting" state — the timer does not begin until the player holds the Focus Node.

### 4.2 The Focus Node Component
- A PositionComponent that uses DragCallbacks.
- **Position:** Centered horizontally, placed in the lower third of the screen. Position is calculated relative to the game's canvas size, not hardcoded.
- **Size:** At least 120x120 dp.
- **Visual:** Renders as a hollow circle or hexagon in Containment Cyan. When held, fills with Muted Teal and scales to 90%.
- **Behavior:**
  - On drag start (finger touches the node): Notify the game that the node is being held. Start the level countdown timer if it hasn't started yet. Fire a light haptic pulse (if haptics are enabled).
  - On drag end or cancel (finger lifts): If the timer is still running, immediately trigger a Containment Breach (failure). Fire heavy haptic impact and error sound.

### 4.3 The Countdown Timer
- A timer managed in the ProtocolGame's update loop or via a Flame Timer.
- Duration is set by the current level configuration (see Phase 5).
- Rendered as a TextComponent at the top-center of the screen using the 64sp Bold SpaceMono style with tabular figures.
- When the timer reaches zero and the Focus Node is still held, trigger the Survived state.

### 4.4 Win/Lose State Handling
- **On Breach (failure):**
  - Pause the Flame engine.
  - Play the error sound (error.flac).
  - Fire heavy haptic feedback.
  - Trigger a brief screen shake on the camera.
  - Show the "GameOver" overlay.
- **On Survived (level complete):**
  - Pause the Flame engine.
  - Update the Restraint Index in shared_preferences (increment highest sequence if this level is a new high, add the level's duration to total time endured).
  - Show the "LevelComplete" overlay.

### 4.5 Pause Functionality
- A small Pause icon component in the top corner of the Flame canvas. It must be at least 48x48 dp.
- On tap: Pause the Flame engine, show the "PauseMenu" overlay. The player can safely lift their finger while paused.
- On resume: Hide the overlay, display a "Re-engage Focus Node" prompt. Once the player holds the node again, run a 3-second countdown, then resume the engine and anomaly spawning.

---

## Phase 5: Level Manager & Anomaly System

**Goal:** Build the system that controls what spawns, when, and how fast — creating the difficulty curve.

### 5.1 Level Configuration
- Create a data structure that defines the parameters for each level:
  - Sequence duration (seconds).
  - Anomaly spawn interval (seconds between spawns).
  - Anomaly movement speed.
  - Which types of anomalies are allowed.
- Levels 1–5 (Tier 1): 10–14 second duration, slow spawn rate, only Static Noise anomalies.
- Levels 6–15 (Tier 2): 12–20 second duration, moderate spawn rate, adds Urgency Trap anomalies.
- Levels 16–25 (Tier 3): 18–30 second duration, fast spawn rate, all anomaly types together, high visual density.
- Levels 26+ (Tier 4 — stretch goal): Same as Tier 3 but adds deceptive anomalies like fake win screens. Only implement this after the core game is fully working.

The level configs can be defined as a simple list or map. For levels beyond the explicitly defined ones, use a formula that gradually tightens spawn rate and increases duration.

### 5.2 Anomaly Base
- All anomalies are PositionComponents with TapCallbacks.
- On any tap: Immediately trigger Containment Breach.
- Each anomaly type defines its own visual appearance and movement behavior.
- All anomalies self-remove when they move fully off-screen or when the sequence ends.

### 5.3 Anomaly Types

**Static Noise (Tier 1):**
- Simple geometric shapes (rectangles, circles) in muted colors.
- Float slowly across the screen in a straight line from one edge to another.
- Not very clickable-looking. Primarily visual noise.

**Urgency Trap (Tier 2):**
- Styled to look like aggressive UI elements: big red "WARNING" boxes, fake "CLEAR CACHE" buttons, fake notification banners.
- Use System Error Red and Hazard Yellow colors with bold SpaceMono text.
- Some are static (appear and stay for a few seconds), some slide across the screen.

**Deceptive Elements (Tier 4 — stretch goal):**
- A fake "Sequence Survived" overlay that appears while the timer still has seconds remaining.
- Timer text that briefly scrambles or shows a fake zero before reverting.
- Only build these after Tiers 1–3 are fully working.

### 5.4 Spawning Logic
- The Level Manager uses a repeating timer that fires based on the current level's spawn interval.
- Each tick, it randomly selects an anomaly type from the current level's allowed pool and spawns it at a random position within the spawn bounds.
- **Spawn bounds:** Full screen minus safe area insets minus 32dp padding on each edge, minus the Focus Node's area plus a buffer. This ensures nothing spawns under the player's thumb or off-screen.
- Each spawned anomaly plays the bait sound effect (bait.wav) if sound is enabled.

### 5.5 Background Audio
- When a sequence starts (Focus Node first held), begin playing the background drone (bg.m4a) on loop.
- When the sequence ends (breach or survived), stop the drone.

---

## Phase 6: Overlays (Game Over, Level Complete, Pause)

**Goal:** Build the Flutter widget overlays that appear over the Flame canvas during state transitions.

### 6.1 Game Over Overlay ("Containment Breach")
- Dark semi-transparent background over the frozen game canvas.
- Centered dialog box with sharp edges and thick border (per Design Language).
- Header text: "CONTAINMENT BREACH" in System Error Red.
- A line of text explaining the failure reason.
- Two buttons:
  - "Reboot Sequence" — restarts the same level (resets the game state, hides overlay, player must re-hold the node).
  - "Return to Terminal" — navigates back to the Main Menu.

### 6.2 Level Complete Overlay ("Sequence Survived")
- Same dialog style but with a calm color scheme (Containment Cyan accents).
- Header: "SEQUENCE SURVIVED" in Containment Cyan.
- Shows the sequence number completed.
- Two buttons:
  - "Next Sequence" — increments the level and resets the game for the next sequence.
  - "Return to Terminal" — navigates back to the Main Menu.

### 6.3 Pause Overlay ("Suspend Protocol")
- Dark semi-transparent background.
- Dialog with two buttons:
  - "Resume Protocol" — hides the overlay and begins the re-engagement flow (player holds node → 3-second countdown → resume).
  - "Abort Sequence" — navigates back to the Main Menu.

All overlays are registered in the GameWidget's overlayBuilderMap and are shown/hidden by the ProtocolGame class when it changes state.

---

## Phase 7: Polish & Integration

**Goal:** Wire up all the loose ends, add the final layer of feel, and make sure everything works together.

### 7.1 Screen Shake
- On Containment Breach, apply a quick camera shake effect (roughly 0.2 seconds of rapid small offset oscillations on the Flame camera). This makes failure feel physical and impactful.

### 7.2 Haptic Integration
- Read the haptics toggle from shared_preferences before firing any haptic calls.
- Light pulse on Focus Node hold.
- Heavy impact on breach.

### 7.3 Audio Integration
- Read the audio toggle from shared_preferences before playing any sounds.
- Preload all audio during the splash screen.
- Background drone loops during active sequences.
- Bait sound on each anomaly spawn.
- Error sound on breach.

### 7.4 Score Persistence
- After every successful sequence, update shared_preferences:
  - If the completed level number is greater than the stored highest, update highest.
  - Add the completed level's duration to the stored total time endured.
- The Restraint Index screen reads and displays these values.

### 7.5 Settings Persistence
- Audio and haptics toggles read from shared_preferences on app start and on each relevant screen.
- Toggling writes immediately to shared_preferences.

### 7.6 Edge Cases to Handle
- **App lifecycle:** If the app goes to background mid-sequence, automatically pause the game (same as tapping the pause button). Resume flow applies when the app comes back.
- **Multi-touch:** Only the Focus Node drag and the Pause button tap should be recognized. Any additional touch on an Anomaly triggers failure. Additional touches on empty background space are ignored (this keeps the mechanic fair).
- **Rapid retries:** When restarting a level, fully clean up all existing anomaly components from the canvas before spawning new ones.

---

## Phase 8: Final Review & Store Readiness

**Goal:** Ensure the game meets Google Play's quality bar and policies.

### 8.1 App Icon
- Use the existing `icon.png` from `assets/images/` as the launcher icon. Configure it in the Android manifest and with the `flutter_launcher_icons` package (or manually place the adaptive icon resources).

### 8.2 Privacy Policy
- The "Data Silence Agreement" screen must be accessible from the main menu.
- The same privacy policy text should be available as a URL (can be a simple hosted page or GitHub Pages) for the Google Play listing.

### 8.3 Content Rating
- The game contains no violence, gambling, user-generated content, or social features. It should qualify for an "Everyone" rating.

### 8.4 Store Listing Assets
- Prepare screenshots of: Terminal (Main Menu), Active Sequence gameplay, Containment Breach screen, Sequence Survived screen.
- Write a short store description emphasizing the unique psychological challenge concept.

### 8.5 Quality Checklist
- All screens are navigable and no dead ends exist.
- The game runs smoothly at 60fps on mid-range Android devices.
- Audio and haptics toggles work correctly.
- Scores persist across app restarts.
- The privacy policy is present and accessible.
- The pause/resume flow works cleanly including the re-engagement countdown.
- No crashes on rapid tapping, quick retries, or app backgrounding.

---

## Build Order Summary

For the most efficient build path, follow this sequence:

1. **Phase 1** — Dependencies, fonts, assets, folder structure.
2. **Phase 2** — Design system constants and app theme.
3. **Phase 3** — All screen shells with navigation (no game logic yet).
4. **Phase 4** — Core game engine: Focus Node, timer, win/lose.
5. **Phase 5** — Level manager, anomaly types, spawning.
6. **Phase 6** — Overlay widgets for pause, game over, level complete.
7. **Phase 7** — Polish: screen shake, audio, haptics, persistence, edge cases.
8. **Phase 8** — Store readiness: icon, privacy URL, screenshots, testing.

Each phase produces a testable result. After Phase 4, you have a playable (if bare) game. After Phase 5, it's a complete game. Phases 6–8 are about feel and release quality.
