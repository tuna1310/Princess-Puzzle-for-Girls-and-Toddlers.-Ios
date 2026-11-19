# Princess Puzzle for Girls and Toddlers (iOS Native Swift)

A **100% Native iOS Swift** recreation of **"Princess puzzle for girls and toddlers"** (App Store ID: `682756571`, Bundle ID: `com.thasmobi.physicsPuzzle05` by Tommy Hass), built with **SwiftUI**, **SpriteKit** (2D rigid-body physics), **CoreGraphics**, **AVFoundation**, and **StoreKit 2**.

---

## 1. Key Features

- **Authentic Rotating Planet Carousel Level Selector (`PlanetWheelScreenView`, `RotatingPlanetWheelView`)**:
  - Reproduces the signature fairy-tale meadow background (sky, clouds, layered rolling green hills, pine & leafy trees, winding blue river with wave ripples, curved wooden plank bridge, winding sandy footpath, wildflowers, and bottom-right daisies).
  - Features the translucent circular wheel disk, 12-o'clock white selector needle, pastel inner planet core with the 3-tower pink/purple castle, and **16 radial fairy-tale puzzles** standing around the planet perimeter.
  - Controlled via the **Top-Left (`↷`) and Top-Right (`↶`) Glossy Blue Curved Rotation Arrow Buttons** or direct touch drag with spring snapping.
- **Physics-Enabled Anatomical Puzzle Gameplay (`PuzzleGameplayScreenView`, `PuzzlePhysicsScene`)**:
  - **Grayscale Upper Target Silhouette**: Renders the chosen character/object in desaturated grayscale (`ipad_5.png`), illuminating each anatomical part in vibrant full color as pieces snap into place (`iphone_2..5.png`).
  - **2D Rigid-Body Physics (`SpriteKit`)**: Loose puzzle pieces drop under 2D gravity (`dy = -6.5`), collide with the meadow floor, screen walls, and each other (`restitution = 0.24`, `friction = 0.48`), and rest at natural tilted angles.
  - **Drag, Auto-Righting & Magnetic Snap**: Touching a piece suspends gravity, elevates the piece, smoothly rights its rotation toward `0°`, and snaps it into its target slot with a sparkle burst and musical chime when dragged within the snap threshold. Dropping a piece in the wrong spot re-engages gravity so it tumbles back into the meadow floor.
- **Interactive Bubble-Pop Surprise Reward (`SurpriseBubbleNode`, `SurpriseCelebrationOverlayView`)**:
  - Completing all pieces of a puzzle triggers a celebratory bounce, royal fanfare, and floating soap bubbles & stars that the toddler can tap and pop!
- **Progress Persistence & State Restoration (`ProgressRepository`)**:
  - Automatically persists completed puzzles, earned stars, active wheel position, sound toggle, StoreKit unlock entitlement, and mid-puzzle placed pieces across app restarts.
- **Kid-Safe Parental Gate & StoreKit 2 In-App Purchase (`ParentalGateModalView`, `StoreService`)**:
  - Levels 1–4 (`Pink Fairy Castle`, `Crown Princess Mia`, `Royal Pink Pony`, `Royal Cherry Ice Cream`) are **Free** by default.
  - Levels 5–16 unlock via the native StoreKit 2 **`"Unlock all puzzles"` (`$2.99`)** Non-Consumable In-App Purchase and **Restore Purchases**, protected by an adult arithmetic **Parental Gate**.

---

## 2. Project Architecture (MVVM)

```text
PrincessPuzzle/
├── PrincessPuzzle.xcodeproj/          # Native Xcode 16 Project & Shared Scheme
├── project.yml                        # XcodeGen specification
├── PrincessPuzzle/
│   ├── App/                           # App entry point & RootContainerView
│   ├── Models/                        # PuzzleLevel, PuzzlePieceModel, PlayerProgress, ParentalChallenge
│   ├── Views/                         # PlanetWheelScreenView, PuzzleGameplayScreenView, SurpriseCelebrationOverlayView
│   ├── ViewModels/                    # AppViewModel, WheelViewModel, GameplayViewModel, StoreViewModel
│   ├── Services/                      # AudioService (AVFoundation WAV synthesizer), StoreService (StoreKit 2)
│   ├── Repositories/                  # PuzzleRepository (16 levels), ProgressRepository (UserDefaults)
│   ├── Game/                          # PuzzlePhysicsScene, PuzzlePieceSpriteNode, SurpriseBubbleNode (SpriteKit)
│   ├── Components/                    # MeadowBackgroundView, RotatingPlanetWheelView, CurvedBlueArrowButton,
│   │                                  # GlossyGreenBackButton, PuzzleIllustrationRenderer, ParentalGateModalView
│   ├── Utilities/                     # ThemeColors, GeometryHelpers
│   └── Resources/                     # Assets.xcassets (AppIcon, AccentColor), Info.plist, PrincessPuzzle.storekit
├── Tests/
│   └── PrincessPuzzleTests.swift      # 9 XCTest unit & integration test suites
├── .github/
│   └── workflows/
│       └── ios-build.yml              # Automated macOS-15 / Xcode 16.4 CI/CD & IPA Export workflow
├── APP_ANALYSIS.md                    # Phase 1 Reverse Engineering Analysis
├── SCREEN_FLOW.md                     # Phase 2 Screen & State Flow Diagrams
├── FEATURE_SPECIFICATION.md           # Phase 2 Detailed Feature Specifications
├── UI_COMPONENTS.md                   # Phase 2 Design Tokens & Custom Components
├── GAMEPLAY_MECHANICS.md              # Phase 2 Physics Model & 16-Level Piece Catalog
├── TECHNICAL_ARCHITECTURE.md          # Phase 3 MVVM & CI/CD Technical Architecture
├── CODE_SIGNING_GUIDE.md              # Phase 8 Mode 1 (Unsigned) & Mode 2 (Signed) IPA Guide
└── TEST_REPORT.md                     # Phase 6 & 9 Automated Verification Report
```

---

## 3. Building & Running Locally on macOS (Xcode 16+)

1. Open `PrincessPuzzle.xcodeproj` in **Xcode 16.0 or later**:
   ```bash
   open PrincessPuzzle.xcodeproj
   ```
2. Select the **`PrincessPuzzle`** scheme and any **iPhone** or **iPad** Simulator (or physical iOS 16.0+ device).
3. Press **Cmd + R** to build and run, or **Cmd + U** to execute the `PrincessPuzzleTests` unit test suite.

---

## 4. Downloading `PrincessPuzzle.ipa` from GitHub Actions

Every push to `main`, release creation, or manual `workflow_dispatch` triggers `.github/workflows/ios-build.yml`:
1. Go to the **GitHub Repository → Actions → iOS Build & Export IPA**.
2. Click the latest successful workflow run.
3. Scroll down to **Artifacts** and click **`PrincessPuzzle-iOS-IPA`** to download the archive containing `PrincessPuzzle.ipa` and `BUILD_REPORT.md` (or download `PrincessPuzzle.ipa` directly from the **Releases** tab).
