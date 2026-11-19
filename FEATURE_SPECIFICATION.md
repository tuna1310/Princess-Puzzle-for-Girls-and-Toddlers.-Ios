# FEATURE SPECIFICATION — Princess Puzzle for Girls and Toddlers

## 1. Functional Scope

Every feature specified in this document is implemented in **100% Native Swift** (`SwiftUI`, `SpriteKit`, `AVFoundation`, `StoreKit`, `CoreGraphics`, `CoreAnimation`) without any third-party SDKs or hybrid wrappers.

---

## 2. Core Feature Specifications

### F-01: 16 Fairy-Tale Puzzles with Progressive Difficulty
The reference application explicitly states: *"It contains 16 puzzles with different difficulty levels. The first few puzzles are free of charge, if you like the application please support us and unlock all puzzles."*

| Level # | Puzzle ID | Title | Theme / Subject | Piece Count | Difficulty | Access Tier |
| :---: | :--- | :--- | :--- | :---: | :---: | :---: |
| **1** | `castle_pink` | **Pink Fairy Castle** | 3-tower pink & purple castle (from `iphone_1.png`) | 5 | Easy (Ages 1–3) | **Free** |
| **2** | `princess_brunette` | **Crown Princess Mia** | Brunette princess in pink crown dress & purse (`iphone_3.png`) | 6 | Easy (Ages 1–3) | **Free** |
| **3** | `royal_pony` | **Royal Pink Pony** | Pink pony with flower, turquoise saddle & pink tail (`iphone_2.png`) | 6 | Easy (Ages 1–3) | **Free** |
| **4** | `cherry_icecream` | **Royal Cherry Ice Cream** | Swirled pink ice cream cone with leaves & cherries (`iphone_4.png`) | 6 | Easy (Ages 1–3) | **Free** |
| **5** | `princess_blonde` | **Ruffle Dress Princess** | Blonde princess in striped bodice & wavy pink skirt (`iphone_5.png`) | 7 | Medium (Ages 3–5) | **IAP Locked** |
| **6** | `princess_flower` | **Flower Bouquet Princess** | Golden-haired princess with daisy bouquet & basket (`ipad_5.png`) | 8 | Medium (Ages 3–5) | **IAP Locked** |
| **7** | `royal_kitty` | **Princess White Kitty** | Crowned white kitten in fairy dress (`iphone_1.png` wheel) | 5 | Easy (Ages 1–3) | **IAP Locked** |
| **8** | `friendly_dragon` | **Friendly Golden Dragon** | Smiling green-gold dragon with orange wings (`iphone_1.png` wheel) | 7 | Medium (Ages 3–5) | **IAP Locked** |
| **9** | `rainbow_palace` | **Enchanted Rainbow Palace** | Turquoise & gold fantasy palace with red spires (`iphone_1.png` wheel) | 8 | Medium (Ages 3–5) | **IAP Locked** |
| **10** | `butterfly_tree` | **Magic Blossom & Butterfly** | Spiral green fairy trees with pink royal butterfly (`iphone_1.png` wheel) | 6 | Easy (Ages 1–3) | **IAP Locked** |
| **11** | `pumpkin_carriage` | **Royal Pumpkin Carriage** | Golden wheels, pink carriage cab, crown roof & lantern | 7 | Medium (Ages 3–5) | **IAP Locked** |
| **12** | `meadow_unicorn` | **Magic Meadow Unicorn** | White & lavender unicorn with golden horn & rainbow tail | 7 | Medium (Ages 3–5) | **IAP Locked** |
| **13** | `royal_treasure` | **Crystal Tiara & Wand** | Jeweled gold tiara, star magic wand, ruby heart & glass slipper | 6 | Medium (Ages 3–5) | **IAP Locked** |
| **14** | `mermaid_princess` | **River Mermaid Princess** | Coral-haired mermaid princess with turquoise tail & seashell | 8 | Hard (Ages 4–6) | **IAP Locked** |
| **15** | `rose_princess` | **Sleeping Rose Princess** | Rose gown princess with tiara, rose vine, cape & golden mirror | 8 | Hard (Ages 4–6) | **IAP Locked** |
| **16** | `grand_ball_princess` | **Grand Royal Ball Princess** | Full ballgown princess with tiara, fan, necklace, ruffles & shoes | 9 | Hard (Ages 4–6) | **IAP Locked** |

---

### F-02: Rotating Planet Carousel Level Selector
- **Circular Planet Wheel**:
  - Displays the translucent dark outer circle, the top 12-o'clock vertical white indicator line, the pastel inner planet core with the central pink castle, and the 16 puzzle characters arranged radially around the globe.
- **Dual Rotation Controls**:
  - **Top-Left Glossy Blue Arrow (`↷`)**: Rotates the planet wheel clockwise to the previous/next puzzle with spring physics.
  - **Top-Right Glossy Blue Arrow (`↶`)**: Rotates the planet wheel counter-clockwise with spring physics.
  - **Direct Touch Drag**: Swiping left/right or dragging angularly around the wheel spins the planet with angular velocity and snaps smoothly to the nearest puzzle stop (`360° / 16 = 22.5°` per stop).
- **Visual State Badges**:
  - Free or unlocked puzzles appear in full vibrant color.
  - Completed puzzles display a golden star/crown badge near the character's feet.
  - Locked puzzles (Levels 5–16 when not purchased) display a clean padlock badge.

---

### F-03: Grayscale Target Silhouette & Anatomical Piece Slicing
- **Target Board**:
  - Renders the complete vector/bitmap illustration of the chosen puzzle in the upper-middle canvas.
  - Unplaced components are rendered in **desaturated grayscale** with subtle inner contour lines so toddlers can visually recognize where each shape belongs.
  - Placed components immediately render in **100% full color** at their exact layer order.
- **Anatomical / Thematic Component Pieces**:
  - Every puzzle is decomposed into distinct, recognizable sub-parts (e.g., crown, hair, head, dress bodice, wavy skirt, legs/shoes, handbag, saddle, tail, cone, scoop, cherries) rather than rectangular grid squares.

---

### F-04: 2D Physics Engine (`SpriteKit`)
- **Gravity & Floor Boundary**:
  - Loose puzzle pieces have active `SKPhysicsBody` instances affected by downward gravity (`dy = -6.5`).
  - Invisible physics edge loop confines pieces to the lower meadow play area (preventing pieces from falling off-screen while allowing them to stack and rest along the meadow path, riverbanks, and wooden bridge).
- **Collisions, Friction & Restitution**:
  - Loose pieces collide with the floor, walls, and other loose pieces with tuned toddler-friendly parameters (`restitution = 0.25`, `friction = 0.45`, `linearDamping = 0.3`, `angularDamping = 0.4`).
  - Pieces naturally tilt (`zRotation`) when resting on uneven stacks, reproducing the tilted loose pieces seen in `iphone_2..5.png` and `ipad_1,2,4,5.png`.
- **Drag, Upright Alignment & Snap-to-Slot**:
  - Touching a piece disables gravity on that piece, elevates its `zPosition`, smoothly animates its `zRotation` toward `0` radians, and tracks the user's finger.
  - Releasing within the snap threshold (`55pt` on iPhone, `75pt` on iPad) snaps the piece into its exact target position with a spring animation and locks it.
  - Releasing outside the snap threshold re-enables dynamic gravity so the piece falls back into the lower meadow.

---

### F-05: Interactive Surprise Reward System
- **Completion Detection**:
  - Triggered immediately when `placedPiecesCount == totalPiecesCount`.
- **Interactive Bubble & Star Pop Mini-Game**:
  - Spawns 18+ floating soap bubbles, golden stars, and princess crowns drifting upward across the meadow with gentle horizontal sine-wave oscillation.
  - Tapping any bubble/star pops it with a burst of sparkles, a pitched pop sound effect, and haptic feedback.
  - Includes a quick-continue button and automatic progression timer so a 1–6 year old never gets stuck.

---

### F-06: Progress Persistence & State Restoration
- **Persistent Storage (`ProgressRepository`)**:
  - Automatically saves:
    - Completed puzzle IDs and completion star counts.
    - Currently selected wheel index (`lastSelectedPuzzleIndex`).
    - In-progress piece placements for the active puzzle (so quitting and relaunching restores the child's exact state!).
    - Audio mute/unmute preferences.
    - StoreKit `"Unlock all puzzles"` entitlement flag.

---

### F-07: Native Audio System (`AVFoundation`)
- **Procedural & Multi-Channel Audio Engine (`AudioService`)**:
  - Synthesizes clean, zero-latency WAV/PCM buffers in memory and plays them via `AVAudioPlayer` / `AVAudioEngine`:
    - Gentle fairy-tale music box / harp background loop (toggleable).
    - Piece pickup pop sound.
    - Piece snap chime (ascending major arpeggio).
    - Piece drop / bounce soft woody thud.
    - Bubble pop sound (random pentatonic pitches).
    - Puzzle completion royal fanfare.

---

### F-08: Native StoreKit 2 In-App Purchase + Parental Gate
- **Product Identifier**: `com.thasmobi.physicsPuzzle05.unlockAll` (Display Name: `"Unlock all puzzles"`, Price: `$2.99`).
- **StoreKit 2 Implementation (`StoreService`)**:
  - Queries `Product.products(for:)`, executes `product.purchase()`, verifies `VerificationResult<Transaction>`, listens to `Transaction.updates`, and supports `AppStore.sync()` for **Restore Purchases**.
  - Includes a built-in **StoreKit Sandbox / Offline Verification Fallback** behind the Parental Gate so reviewers and automated UI/unit tests can verify the complete purchase and unlock lifecycle even when running in an unsigned CI/Simulator environment.
