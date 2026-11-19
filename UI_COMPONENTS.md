# UI COMPONENTS — Princess Puzzle for Girls and Toddlers

## 1. Visual Design System & Color Palette

All color tokens are sampled directly from the 10 official App Store screenshots (`iphone_1..5.png`, `ipad_1..5.png`) and the `512x512` App Icon (`icon_512.jpg`).

### 1.1 Meadow Landscape Palette
| Token Name | Hex Code | RGB | Usage in Reference App |
| :--- | :--- | :--- | :--- |
| `skyTopBlue` | `#83C5F2` | `(131, 197, 242)` | Upper sky gradient on Planet Carousel screen |
| `skyHorizonBlue` | `#CBE9FB` | `(203, 233, 251)` | Lower sky near hills |
| `meadowHillLight` | `#9EC93B` | `(158, 201, 59)` | Distant sun-lit rolling hill |
| `meadowHillMid` | `#74A327` | `(116, 163, 39)` | Midground rolling green hill |
| `meadowHillDeep` | `#55841D` | `(85, 132, 29)` | Foreground green hill and riverbank slope |
| `forestPineGreen` | `#2D6D36` | `(45, 109, 54)` | Stylized pine and deciduous tree clusters |
| `riverBlue` | `#1274BA` | `(18, 116, 186)` | Winding river crossing lower meadow |
| `riverWaveHighlight` | `#62ACE0` | `(98, 172, 224)` | Water wave crests in river |
| `woodenBridgeBrown` | `#A97B2B` | `(169, 123, 43)` | Curved wooden plank bridge over river |
| `sandyPathGold` | `#DFD06B` | `(223, 208, 107)` | Winding sandy footpath from bottom to bridge |
| `daisyPetalWhite` | `#F9FBFD` | `(249, 251, 253)` | Bottom-right daisies & scattered meadow wildflowers |
| `daisyCenterYellow` | `#F5D618` | `(245, 214, 24)` | Yellow centers of bottom-right daisies |

### 1.2 Character & Fairy-Tale Artwork Palette
| Token Name | Hex Code | Usage |
| :--- | :--- | :--- |
| `princessDressPink` | `#EE3E96` | Primary magenta-pink princess dresses & pony mane |
| `princessPastelPink` | `#F9B5D4` | Light pink pony body, castle walls, ice cream swirls |
| `castleRoofPurple` | `#9A1D89` | Fairy castle turret roofs & flags |
| `crownGold` | `#F8C423` | Princess crowns, stars, and dragon scales |
| `saddleTurquoise` | `#72CEDB` | Pony saddle, rainbow palace walls, flower accents |
| `silhouetteGrayLight` | `#BCBCBC` | Unplaced puzzle silhouette highlight tone |
| `silhouetteGrayMid` | `#8E8E8E` | Unplaced puzzle silhouette body tone |
| `silhouetteGrayDark` | `#686868` | Unplaced puzzle silhouette contour/detail tone |

### 1.3 Interactive Control Buttons Palette
| Component | Primary Gradient | Border / Outline | Drop Shadow |
| :--- | :--- | :--- | :--- |
| **Blue Curved Rotate Arrows (`↷` / `↶`)** | `#4A89DC` → `#1B4F9C` with glossy top highlight `#8BB8F2` | `#133873` (`2pt`) + inner `#A6CAF8` (`1.5pt`) | Elliptical ground shadow `rgba(0,0,0,0.35)` |
| **Green Back Arrow (`⬅`)** | `#B7F26A` → `#62C422` with glossy top highlight `#DCFBAC` | `#147202` (`3.5pt` rounded contour) | Soft drop shadow `rgba(0,0,0,0.28)` |

---

## 2. Custom Native UI Components

### 2.1 `MeadowBackgroundView` (`PrincessPuzzle/Components/MeadowBackgroundView.swift`)
- **Purpose**: Renders the exact portrait fairy-tale meadow background seen in every screenshot using native `CoreGraphics` / SwiftUI `Canvas`.
- **Layers**:
  1. Sky gradient + fluffy multi-lobed clouds.
  2. Four overlapping Bézier rolling green hills with pine and round-canopy trees.
  3. Winding blue S-curve river with animated subtle wave ripples.
  4. Winding golden-sand footpath from bottom-center through the bridge into the hills.
  5. Curved wooden plank bridge with individual timber slats across the river.
  6. Clustered 5-petal tiny white wildflowers along the path and two large 6-petal daisies at the bottom-right corner.
  7. Configurable `dimmingOpacity` (`0.0` on Planet Carousel screen; `0.18` on Gameplay screen).

### 2.2 `RotatingPlanetWheelView` (`PrincessPuzzle/Components/RotatingPlanetWheelView.swift`)
- **Purpose**: Reproduces the central rotating planet level selector from `iphone_1.png` and `ipad_3.png`.
- **Visual Elements**:
  - **Outer Translucent Circle**: Diameter `min(screenWidth * 0.95, screenHeight * 0.72)`, fill `rgba(55, 62, 68, 0.36)`.
  - **Top 12-o'clock Selector Line**: White `2pt` vertical line extending from the top rim of the outer circle down to the inner planet core.
  - **Inner Planet Sphere**: Diameter `48%` of outer circle, upper hemisphere soft pastel pink (`#F8DCE8`), lower hemisphere creamy yellow (`#FDF3B7`), containing the central 3-tower pink/purple castle (`CastleCoreIllustration`).
  - **Radial Character Nodes**: Positions the puzzle illustrations around the planet's perimeter at angle $\theta_i = i \times \frac{2\pi}{N} + \text{wheelRotation}$, rotated so every character's feet rest on the inner planet surface pointing radially outward.
  - **Decorative Orbit Accents**: Golden sun rays, fluttering pink/yellow butterflies, and spiral green fairy trees rotating harmoniously with the planet.

### 2.3 `CurvedBlueArrowButton` (`PrincessPuzzle/Components/CurvedBlueArrowButton.swift`)
- **Purpose**: Reproduces the top-left clockwise (`↷`) and top-right counter-clockwise (`↶`) glossy blue curved arrow buttons from `iphone_1.png` and `ipad_3.png`.
- **Dimensions**: `64 x 54 pt` on iPhone, `84 x 70 pt` on iPad, with tactile press-scale feedback (`0.92x` on press) and floating elliptical ground shadow beneath the arrow.

### 2.4 `GlossyGreenBackButton` (`PrincessPuzzle/Components/GlossyGreenBackButton.swift`)
- **Purpose**: Reproduces the chunky glossy green left arrow button (`⬅`) at the top-left of `iphone_2..5.png` and `ipad_1,2,4,5.png`.
- **Dimensions**: `62 x 52 pt` on iPhone, `80 x 68 pt` on iPad, drawn with thick dark-green outer stroke (`#147202`), vibrant lime-green gradient fill (`#B8F26E` → `#5EC01E`), and upper glossy specular highlight.

### 2.5 `PuzzleIllustrationRenderer` (`PrincessPuzzle/Components/PuzzleIllustrationRenderer.swift`)
- **Purpose**: High-resolution native CoreGraphics vector renderer that draws all 16 fairy-tale puzzles and generates:
  1. The full assembled preview image (for the Rotating Planet Carousel).
  2. Individual full-color anatomical/component piece textures (`SKTexture` / `UIImage`) with transparent backgrounds.
  3. Desaturated grayscale component textures (`saturation = 0`) for the upper target silhouette board.

### 2.6 `ParentalGateModalView` & `StoreUnlockModalView` (`PrincessPuzzle/Components/ParentalGateModalView.swift`)
- **Purpose**: Kid-safe arithmetic gate protecting the StoreKit `"Unlock all puzzles ($2.99)"` purchase and `"Restore Purchases"` actions.

---

## 3. Responsive Layout Specifications (iPhone & iPad Universal)

| Layout Parameter | iPhone Portrait (`Compact Width`) | iPad Portrait (`Regular Width`) |
| :--- | :--- | :--- |
| **Planet Outer Wheel Diameter** | `94%` of screen width (`~368 pt`) | `82%` of screen width (`~630 pt`) |
| **Planet Inner Core Diameter** | `46%` of outer wheel (`~170 pt`) | `46%` of outer wheel (`~290 pt`) |
| **Top Corner Arrow Padding** | `16 pt` horizontal, `12 pt` top safe area | `28 pt` horizontal, `20 pt` top safe area |
| **Gameplay Target Silhouette Center** | `(x: 50% W, y: 31% H)` | `(x: 50% W, y: 32% H)` |
| **Gameplay Target Silhouette Size** | `250 x 270 pt` | `380 x 410 pt` |
| **Physics Floor Spawn Zone** | Lower `42%` of screen (`y: 58%..92% H`) | Lower `42%` of screen (`y: 58%..92% H`) |
| **Piece Snap Distance Threshold** | `55 pt` | `75 pt` |
