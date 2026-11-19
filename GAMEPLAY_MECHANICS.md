# GAMEPLAY MECHANICS — Princess Puzzle for Girls and Toddlers

## 1. Core Gameplay Loop

1. **Spin & Pick on the Fairy-Tale Planet**:
   - The child taps the top-left (`↷`) or top-right (`↶`) blue curved arrow (or swipes the planet wheel) to rotate the 16 fairy-tale characters around the central castle planet.
   - Tapping the top-selected character (or any unlocked character around the planet) launches that puzzle.
2. **Observe Grayscale Silhouette & Falling Physics Pieces**:
   - The complete puzzle character appears in the upper-middle sky/hill zone as a **grayscale template**.
   - Simultaneously, the character's colored anatomical/thematic pieces drop into the lower river/bridge meadow zone under **real 2D gravity**, bouncing gently off the meadow floor and resting against one another at natural tilted angles.
3. **Drag, Right & Snap**:
   - When the toddler touches a piece in the lower meadow:
     - The piece detaches from gravity, rises to the front layer, smoothly rotates back to its upright (`0°`) orientation, and follows the child's finger.
   - **Correct Match (Snap)**:
     - If the piece is dragged within the snap radius of its matching grayscale region on the upper template, it snaps into place with a magnetic spring easing, locks into the template, triggers a sparkle burst and musical chime, and illuminates that section of the grayscale template in vibrant full color.
   - **Incorrect Match (Physics Drop)**:
     - If the piece is released outside its target snap radius, gravity immediately re-engages and the piece tumbles back down into the lower meadow floor, colliding dynamically with the ground, walls, and any remaining loose pieces.
4. **Interactive Bubble-Pop Surprise Celebration**:
   - When the final piece snaps into place, the completed character celebrates with a joyful bounce and royal fanfare.
   - Colorful bubbles, stars, and golden crowns float up from the river and meadow for the toddler to tap and pop!

---

## 2. Physics Engine Mathematical Model (`SpriteKit`)

### 2.1 World Parameters
- **Gravity Vector**:
  $$\vec{g} = (0, -6.5)\,\text{m/s}^2$$
  Tuned specifically for ages 1–6 so pieces fall visibly and playfully without snapping too fast or feeling heavy.
- **Playable Physics Floor Envelope**:
  - An `SKPhysicsBody(edgeLoopFrom: playableBounds)` encloses the scene so no piece can ever escape off-screen.
  - The floor line is positioned above the bottom edge (`y = 28 pt` in SpriteKit coordinates), with subtle invisible terrain ledges matching the riverbank so pieces scatter across different heights in the lower half of the screen (just like `iphone_2..5.png` and `ipad_1,2,4,5.png`).

### 2.2 Rigid-Body Properties per Puzzle Piece
| Parameter | Value | Purpose |
| :--- | :--- | :--- |
| `isDynamic` | `true` (when loose), `false` (when dragged or snapped) | Enables gravity & collisions only for loose pieces |
| `AffectedByGravity` | `true` (when loose), `false` (when dragged or snapped) | Suspends gravity during finger drag |
| `restitution` | `0.24` | Gentle, child-friendly bounce upon landing |
| `friction` | `0.48` | Prevents pieces from sliding endlessly |
| `linearDamping` | `0.35` | Smooth air resistance |
| `angularDamping` | `0.45` | Allows natural tilt without chaotic spinning |
| `categoryBitMask` | `PhysicsCategory.puzzlePiece` (`0x1 << 0`) | Piece collision group |
| `collisionBitMask` | `PhysicsCategory.boundary \| PhysicsCategory.puzzlePiece` | Pieces collide with walls/floor and with each other |

### 2.3 Touch Drag & Smooth Orientation Recovery
When a piece is being dragged to touch point $P_{\text{touch}}(t)$:
- Position is updated via critically damped interpolation or direct tracking clamped within screen bounds:
  $$P_{\text{piece}}(t) = \text{clamp}(P_{\text{touch}}(t), \text{safeMargins})$$
- Angular rotation smoothly interpolates toward `0` radians (`SKAction.rotate(toAngle: 0, duration: 0.18, shortestUnitArc: true)`), ensuring the piece is upright when the child aligns it with the upper grayscale silhouette.

### 2.4 Snap-to-Target Criterion
Each piece $k \in \{1, \dots, M\}$ has an exact target center $T_k = (x_k^*, y_k^*)$ in scene coordinates on the upper grayscale silhouette board.
- Euclidean distance from piece center $P_k$ to target center $T_k$:
  $$d_k = \sqrt{(P_{k,x} - x_k^*)^2 + (P_{k,y} - y_k^*)^2}$$
- **Auto-Snap Condition**:
  - During drag (`touchesMoved`), if $d_k \le r_{\text{magnetic}}$ (`32 pt` on iPhone, `44 pt` on iPad), or upon release (`touchesEnded`), if $d_k \le r_{\text{snap}}$ (`58 pt` on iPhone, `78 pt` on iPad):
    1. Piece immediately locks (`isLocked = true`, `physicsBody = nil`).
    2. Animates to $T_k$ with `zRotation = 0` over `0.16s` with a scale pop (`1.08 -> 1.0`).
    3. Emits star particle burst and plays ascending snap chime.
    4. Notifies `GameplayViewModel` to mark piece $k$ as placed and persist progress.

---

## 3. Anatomical Piece Decomposition Catalog (All 16 Puzzles)

Every single puzzle in the game uses authentic component/anatomical decomposition matching the reference screenshots:

1. **Level 1 — Pink Fairy Castle (`castle_pink`, 5 pieces)**:
   - Central Main Keep & Gate, Left Tower & Turret, Right Tower & Turret, Top Spire & Waving Flags, Royal Sun & Butterfly Crest.
2. **Level 2 — Crown Princess Mia (`princess_brunette`, 6 pieces — matches `iphone_3.png` & `ipad_1.png`)**:
   - Golden Crown & Pink Hair Flower, Chestnut Hair & Smiling Head, Pink Crown-Patterned Dress Bodice & Skirt, Left & Right Arms, Pink Purse with Pencils, Left & Right Legs with Pink/Grey Shoes.
3. **Level 3 — Royal Pink Pony (`royal_pony`, 6 pieces — matches `iphone_2.png` & `ipad_2.png`)**:
   - Pony Head & Neck with Pink Flower, Front Torso & Forelegs, Pink Hind Legs, Pony Back & Rump, Turquoise Saddle & Stirrup, Flowing Hot-Pink Tail.
4. **Level 4 — Royal Cherry Ice Cream (`cherry_icecream`, 6 pieces — matches `iphone_4.png`)**:
   - Lower Waffle Cone Tip, Upper Waffle Cone Wrapper, Pink & Cream Swirled Scoop, Left Green Leaf Fan, Right Green Leaf Fan, Twin Red Cherries with Stems.
5. **Level 5 — Ruffle Dress Princess (`princess_blonde`, 7 pieces — matches `iphone_5.png` & `ipad_4.png`)**:
   - Pink Jeweled Crown, Golden Blonde Hair & Smiling Face, Pink Striped Bodice & Arms, Blue Waist Flower Belt, Hot-Pink Wavy Overskirt, Light-Pink Wavy Underskirt Ruffle, Legs & Blue Flower Shoes.
6. **Level 6 — Flower Bouquet Princess (`princess_flower`, 8 pieces — matches `ipad_5.png`)**:
   - Royal Tiara, Wavy Golden Hair, Smiling Face & Neck, Daisy-Belted Bodice, Left Magenta Skirt Panel, Right Magenta Skirt Panel, Left Arm & Legs, Right Arm with Flower Bouquet & Basket.
7. **Level 7 — Princess White Kitty (`royal_kitty`, 5 pieces — matches `iphone_1.png`)**:
   - Golden Kitty Crown, White Kitty Head & Whiskers, White Fairy Gown with Daisy, Fluffy White Tail & Paws, Pink Royal Handbag.
8. **Level 8 — Friendly Golden Dragon (`friendly_dragon`, 7 pieces — matches `iphone_1.png`)**:
   - Smiling Dragon Head & Horns, Upper Scaled Neck, Curled Golden Tail, Left Orange Dragon Wing, Right Orange Dragon Wing, Front Claws, Hind Legs.
9. **Level 9 — Enchanted Rainbow Palace (`rainbow_palace`, 8 pieces — matches `iphone_1.png`)**:
   - Central Turquoise Palace Hall, Left Patterned Gold Wing, Right Patterned Gold Wing, Red Center Archway, Left Crimson Spire & Flag, Center Golden Spire & Flag, Right Crimson Spire & Flag, Royal Butterfly & Banner.
10. **Level 10 — Magic Blossom & Butterfly (`butterfly_tree`, 6 pieces — matches `iphone_1.png`)**:
    - Red Tree Trunk & Branches, Left Spiral Green Canopy, Center Spiral Green Canopy, Right Spiral Green Canopy, Pink Royal Butterfly, Meadow Blossom Cluster.
11. **Level 11 — Royal Pumpkin Carriage (`pumpkin_carriage`, 7 pieces)**:
    - Golden Crown Roof, Pink Pumpkin Coach Body, Royal Window & Curtains, Left Golden Spoke Wheel, Right Golden Spoke Wheel, Coachman Lantern, Velvet Entry Steps.
12. **Level 12 — Magic Meadow Unicorn (`meadow_unicorn`, 7 pieces)**:
    - Golden Spiral Horn & Crown, Unicorn Head & Lavender Mane, White Body & Star Flank, Front Legs & Golden Hooves, Hind Legs & Golden Hooves, Rainbow Flowing Tail, Floral Neck Garland.
13. **Level 13 — Crystal Tiara & Wand (`royal_treasure`, 6 pieces)**:
    - Golden Royal Tiara Base, Pink Diamond Center Jewel, Magic Star Wand, Ruby Heart Locket, Left Glass Slipper, Right Glass Slipper.
14. **Level 14 — River Mermaid Princess (`mermaid_princess`, 8 pieces)**:
    - Seashell Tiara, Flowing Coral Hair, Smiling Mermaid Head, Pearl Shell Top, Left & Right Arms, Upper Turquoise Scaled Tail, Lower Tail Fin, Friendly Pink Starfish Companion.
15. **Level 15 — Sleeping Rose Princess (`rose_princess`, 8 pieces)**:
    - Golden Rose Crown, Long Auburn Hair, Smiling Princess Face, Rose Corset Bodice, Flowing Velvet Cape, Layered Rose Gown Skirt, Glass Slippers, Enchanted Spinning Rose Spindle.
16. **Level 16 — Grand Royal Ball Princess (`grand_ball_princess`, 9 pieces)**:
    - Diamond Star Tiara, Royal Updo Hairstyle, Smiling Princess Head & Ruby Necklace, Embroidered Gold Bodice, Left Gloved Arm with Feather Fan, Right Gloved Arm, Upper Magenta Ballgown Peplum, Lower Golden Ballgown Skirt, Crystal Dancing Shoes.
