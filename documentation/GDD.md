# Game Design Document: "Don't Tap: Rogue Op"

## 1. Game Identity

- **Title:** Don't Tap: Rogue Op
- **Theme:** Rogue Operating System / Psychological Testing Facility
- **Engine:** Flutter + Flame
- **Platform:** Android (Google Play)
- **Monetization:** None (free, offline, no ads for v1)
- **Data:** Fully offline. No personal data collected. Scores stored locally on device only.

The player is an "Operator" testing a volatile system. Their only job is to maintain system stability by holding a central node, while the system actively tries to trick them into breaking protocol. Every UI element, screen name, and piece of copy uses "System UI" terminology to reinforce this theme.

---

## 2. Core Gameplay Loop

1. **Engage:** The player presses and holds the "Focus Node" (a central interactive element on screen).
2. **Endure:** A countdown timer begins. The screen fills with "Anomalies" — flashing fake errors, fake rewards, and moving targets designed to trigger a reflex tap.
3. **Survive or Fail:**
   - **Survive:** The timer reaches zero while the player is still holding the Focus Node. Sequence complete.
   - **Fail (Containment Breach):** The player lifts their finger from the Focus Node before the timer ends, OR the player taps any Anomaly with a second finger.

This is the entire game. The challenge is purely psychological — resisting the urge to react.

---

## 3. Player Mechanics

- **The Focus Node (Anchor):** A clearly marked, stable zone in the lower-center of the screen. The player must touch it and hold continuously. When held, it changes color to confirm the hold is registered.
- **The Anomalies (Bait):** Various fake UI elements that spawn dynamically during a sequence. They are designed to look tappable and urgent. They have tap detection — any tap on them triggers instant failure.
- **Failure Triggers:**
  1. Lifting your finger from the Focus Node before the timer hits zero.
  2. Tapping any Anomaly with a second finger.
- **Safe Interactions:** The only element the player can safely interact with (besides holding the Focus Node) is the Pause button in the top corner. Tapping anywhere else on the background does NOT cause failure — only tapping a specific Anomaly does. This keeps the mechanic fair and the pause button usable.

---

## 4. Screens & Navigation

All screens use the "Rogue OS" theme. Navigation is handled through Flutter routing and Flame overlays.

### 4.1 System Boot (Splash Screen)
- A stark black screen with the game logo and a minimal loading indicator.
- Preloads audio assets and fonts. Transitions automatically to the Terminal after a brief delay.

### 4.2 The Terminal (Main Menu)
The hub screen. All options presented as system commands:
- **Initiate Sequence** — Starts gameplay.
- **Operator Manual** — Opens the how-to-play screen.
- **System Calibration** — Opens settings (audio on/off, haptics on/off).
- **Restraint Index** — Shows the player's progression (highest sequence reached, total time endured).
- **Data Silence Agreement** — Privacy policy text (mandatory for Google Play compliance).

### 4.3 Operator Manual (How to Play)
A simple, 3-step visual guide:
1. Hold the Focus Node.
2. Ignore all System Anomalies.
3. Survive the timer.

### 4.4 Active Sequence (Gameplay Screen)
The core Flame game canvas:
- The Focus Node is centered in the lower third of the screen.
- A large countdown timer is displayed at the top.
- Anomalies spawn and animate across the available screen area.
- A small, unobtrusive Pause icon sits in the top corner.

### 4.5 Suspend Protocol (Pause Menu)
- Triggered by tapping the Pause icon.
- The game engine pauses. A dark overlay appears over the frozen game canvas.
- Options: "Resume Protocol" or "Abort Sequence" (quit to Terminal).
- On resume, the player must re-hold the Focus Node, then a brief 3-second countdown plays before Anomalies resume.

### 4.6 Sequence Survived (Level Complete)
- A calm, cool-toned screen. The chaos stops.
- Displays the sequence number survived.
- Options: "Next Sequence" or "Return to Terminal."

### 4.7 Containment Breach (Game Over)
- A harsh, jarring red-toned screen.
- Displays a brief reason for failure (e.g., "Premature Node Release" or "Unauthorized Input Detected").
- Options: "Reboot Sequence" (retry same level) or "Return to Terminal."

### 4.8 Data Silence Agreement (Privacy Policy)
- A simple scrollable text screen declaring: the game is fully offline, collects no personal data, and uses local storage only for scores.

### 4.9 System Calibration (Settings)
- Toggle for sound effects on/off.
- Toggle for haptic feedback on/off.
- Settings saved locally using shared preferences.

---

## 5. Level Structure & Progression

Difficulty scales by increasing the psychological pressure, not by adding mechanical complexity.

### Scaling Variables
1. **Sequence Duration:** How long the player must hold (starts at 10 seconds, scales up to 30 seconds).
2. **Anomaly Spawn Rate:** How frequently new bait appears (interval decreases as levels increase).
3. **Anomaly Speed:** How fast moving anomalies travel across screen.
4. **Anomaly Deceptiveness:** The type and visual design of anomalies that appear.

### Progression Tiers

**Tier 1: Static Noise (Levels 1–5)**
- Simple geometric shapes float slowly across the screen. They don't look very clickable.
- Purpose: Teach the player the core mechanic of holding the Node and building comfort.

**Tier 2: The Urgency Trap (Levels 6–15)**
- Aggressive fake UI elements appear: flashing red "WARNING" buttons, fake "CLEAR CACHE" prompts, fake notification banners.
- Spawn rate increases. Elements move faster.
- Purpose: Test reflex suppression against familiar-looking UI patterns.

**Tier 3: Escalation (Levels 16–25)**
- All previous anomaly types appear together. Spawn rate is high. Multiple anomalies on screen simultaneously.
- Timer durations are longer (20–30 seconds), testing sustained focus.
- Anomalies may briefly overlap near (but not on top of) the Focus Node to increase tension.
- Purpose: Sustained psychological endurance under heavy visual noise.

**Tier 4: System Deception (Levels 26+)**
- The game introduces deceptive anomalies: a fake "Sequence Survived" button that appears while the timer still has seconds left, or timer text that briefly scrambles to cause panic.
- This tier is an aspirational stretch goal. It can be added after the core game is solid. The game is fully complete and shippable with just Tiers 1–3.

---

## 6. Scoring System (The Restraint Index)

Levels are binary: pass or fail. There are no points per level.

- **Highest Sequence Reached:** The maximum level number the player has completed. This is the primary progression metric.
- **Total Time Endured:** A cumulative counter of all seconds successfully survived across all play sessions. Provides a sense of meta-progression even when stuck on a hard level.

Both values are stored locally using shared preferences. There is no online leaderboard.

---

## 7. Audio Design

The game uses minimal, impactful audio to reinforce the tension. All audio files are bundled in the app (no streaming).

### Audio Assets (already present in assets/audio/)
- **bg.m4a** — A low, ambient background drone that plays during active sequences. Should feel tense and sterile, like a system humming.
- **bait.wav** — A short, sharp sound that plays when a new Anomaly spawns on screen. Designed to grab attention and tempt a reaction.
- **error.flac** — A harsh, jarring error sound that plays on failure (Containment Breach). Paired with heavy haptic feedback.

Audio should be preloaded during the splash screen so there is zero delay during gameplay.

---

## 8. Haptic Feedback

- **Light pulse:** When the player first presses and holds the Focus Node (confirms engagement).
- **Heavy impact:** The instant the player fails — lifts their finger or taps an anomaly. This should feel physically jarring, paired with the error sound.

Haptics must be toggleable in System Calibration (Settings).

---

## 9. Existing Assets Summary

| Asset | Location | Purpose |
|---|---|---|
| SpaceMono-Regular.ttf | assets/font/ | Primary UI font |
| SpaceMono-Bold.ttf | assets/font/ | Bold variant for headers and timer |
| SpaceMono-Italic.ttf | assets/font/ | Italic variant (minor use) |
| SpaceMono-BoldItalic.ttf | assets/font/ | Bold italic variant (minor use) |
| logo.png | assets/images/ | Game logo, used on splash screen and Terminal |
| icon.png | assets/images/ | App icon for the launcher |
| bg.m4a | assets/audio/ | Background ambient drone during gameplay |
| bait.wav | assets/audio/ | Anomaly spawn sound effect |
| error.flac | assets/audio/ | Failure/breach sound effect |
