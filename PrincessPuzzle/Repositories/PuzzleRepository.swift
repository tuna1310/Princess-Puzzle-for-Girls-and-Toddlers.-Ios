import CoreGraphics
import Foundation

/// Protocol for accessing the 16 puzzle definitions.
public protocol PuzzleRepositoryProtocol: Sendable {
    func allLevels() -> [PuzzleLevel]
    func level(withID id: String) -> PuzzleLevel?
    func level(atIndex index: Int) -> PuzzleLevel?
}

/// Official catalog of the 16 fairy-tale puzzles matching "Princess puzzle for girls and toddlers" (`id682756571`).
public final class PuzzleRepository: PuzzleRepositoryProtocol, Sendable {
    public static let shared = PuzzleRepository()

    private let catalog: [PuzzleLevel]

    public init() {
        self.catalog = Self.buildCatalog()
    }

    public func allLevels() -> [PuzzleLevel] {
        catalog
    }

    public func level(withID id: String) -> PuzzleLevel? {
        catalog.first { $0.id == id }
    }

    public func level(atIndex index: Int) -> PuzzleLevel? {
        guard !catalog.isEmpty else { return nil }
        let safeIndex = ((index % catalog.count) + catalog.count) % catalog.count
        return catalog[safeIndex]
    }

    // MARK: - 16 Verified & Reconstructed Fairy-Tale Puzzles

    private static func buildCatalog() -> [PuzzleLevel] {
        [
            // 1. Pink Fairy Castle (Free - shown at 12 o'clock on wheel in iphone_1.png)
            PuzzleLevel(
                id: "castle_pink",
                index: 0,
                title: "Pink Fairy Castle",
                subtitle: "Royal Castle on the Hill",
                archetype: .pinkCastle,
                difficulty: .easy,
                isFreeByDefault: true,
                pieces: [
                    PuzzlePieceDefinition(id: "castle_pink_p0", partIndex: 0, name: "Royal Sun & Butterfly Crest", normalizedCenterX: 0.50, normalizedCenterY: 0.14, normalizedWidth: 0.58, normalizedHeight: 0.22, zIndex: 1),
                    PuzzlePieceDefinition(id: "castle_pink_p1", partIndex: 1, name: "Central Spire & Flag", normalizedCenterX: 0.50, normalizedCenterY: 0.34, normalizedWidth: 0.30, normalizedHeight: 0.34, zIndex: 3),
                    PuzzlePieceDefinition(id: "castle_pink_p2", partIndex: 2, name: "Left Castle Tower", normalizedCenterX: 0.25, normalizedCenterY: 0.56, normalizedWidth: 0.26, normalizedHeight: 0.52, zIndex: 2),
                    PuzzlePieceDefinition(id: "castle_pink_p3", partIndex: 3, name: "Right Castle Tower", normalizedCenterX: 0.75, normalizedCenterY: 0.56, normalizedWidth: 0.26, normalizedHeight: 0.52, zIndex: 2),
                    PuzzlePieceDefinition(id: "castle_pink_p4", partIndex: 4, name: "Main Keep & Royal Gate", normalizedCenterX: 0.50, normalizedCenterY: 0.70, normalizedWidth: 0.44, normalizedHeight: 0.42, zIndex: 4)
                ]
            ),

            // 2. Crown Princess Mia (Free - shown in icon_512.jpg, iphone_3.png, ipad_1.png)
            PuzzleLevel(
                id: "princess_brunette",
                index: 1,
                title: "Crown Princess Mia",
                subtitle: "Princess with Royal Purse",
                archetype: .brunettePrincess,
                difficulty: .easy,
                isFreeByDefault: true,
                pieces: [
                    PuzzlePieceDefinition(id: "princess_brunette_p0", partIndex: 0, name: "Golden Crown & Hair Flower", normalizedCenterX: 0.50, normalizedCenterY: 0.12, normalizedWidth: 0.36, normalizedHeight: 0.18, zIndex: 5),
                    PuzzlePieceDefinition(id: "princess_brunette_p1", partIndex: 1, name: "Chestnut Hair & Smiling Face", normalizedCenterX: 0.48, normalizedCenterY: 0.28, normalizedWidth: 0.52, normalizedHeight: 0.32, zIndex: 3),
                    PuzzlePieceDefinition(id: "princess_brunette_p2", partIndex: 2, name: "Outstretched Princess Arms", normalizedCenterX: 0.48, normalizedCenterY: 0.48, normalizedWidth: 0.72, normalizedHeight: 0.22, zIndex: 2),
                    PuzzlePieceDefinition(id: "princess_brunette_p3", partIndex: 3, name: "Pink Crown-Patterned Dress", normalizedCenterX: 0.46, normalizedCenterY: 0.55, normalizedWidth: 0.44, normalizedHeight: 0.36, zIndex: 4),
                    PuzzlePieceDefinition(id: "princess_brunette_p4", partIndex: 4, name: "Pink Handbag & Pencils", normalizedCenterX: 0.79, normalizedCenterY: 0.52, normalizedWidth: 0.28, normalizedHeight: 0.28, zIndex: 6),
                    PuzzlePieceDefinition(id: "princess_brunette_p5", partIndex: 5, name: "Princess Legs & Slippers", normalizedCenterX: 0.50, normalizedCenterY: 0.83, normalizedWidth: 0.42, normalizedHeight: 0.28, zIndex: 1)
                ]
            ),

            // 3. Royal Pink Pony (Free - shown in iphone_2.png, ipad_2.png)
            PuzzleLevel(
                id: "royal_pony",
                index: 2,
                title: "Royal Pink Pony",
                subtitle: "Meadow Pony with Flower",
                archetype: .royalPony,
                difficulty: .easy,
                isFreeByDefault: true,
                pieces: [
                    PuzzlePieceDefinition(id: "royal_pony_p0", partIndex: 0, name: "Pony Head, Mane & Flower", normalizedCenterX: 0.70, normalizedCenterY: 0.24, normalizedWidth: 0.46, normalizedHeight: 0.38, zIndex: 5),
                    PuzzlePieceDefinition(id: "royal_pony_p1", partIndex: 1, name: "Front Chest & Forelegs", normalizedCenterX: 0.66, normalizedCenterY: 0.58, normalizedWidth: 0.30, normalizedHeight: 0.46, zIndex: 4),
                    PuzzlePieceDefinition(id: "royal_pony_p2", partIndex: 2, name: "Turquoise Saddle & Stirrup", normalizedCenterX: 0.49, normalizedCenterY: 0.47, normalizedWidth: 0.26, normalizedHeight: 0.34, zIndex: 6),
                    PuzzlePieceDefinition(id: "royal_pony_p3", partIndex: 3, name: "Pony Back & Rump", normalizedCenterX: 0.38, normalizedCenterY: 0.44, normalizedWidth: 0.32, normalizedHeight: 0.28, zIndex: 3),
                    PuzzlePieceDefinition(id: "royal_pony_p4", partIndex: 4, name: "Pink Hind Legs & Hooves", normalizedCenterX: 0.36, normalizedCenterY: 0.70, normalizedWidth: 0.28, normalizedHeight: 0.42, zIndex: 2),
                    PuzzlePieceDefinition(id: "royal_pony_p5", partIndex: 5, name: "Flowing Hot-Pink Tail", normalizedCenterX: 0.16, normalizedCenterY: 0.52, normalizedWidth: 0.26, normalizedHeight: 0.42, zIndex: 1)
                ]
            ),

            // 4. Royal Cherry Ice Cream (Free - shown in iphone_4.png)
            PuzzleLevel(
                id: "cherry_icecream",
                index: 3,
                title: "Royal Cherry Ice Cream",
                subtitle: "Sweet Swirl Cone",
                archetype: .cherryIceCream,
                difficulty: .easy,
                isFreeByDefault: true,
                pieces: [
                    PuzzlePieceDefinition(id: "cherry_icecream_p0", partIndex: 0, name: "Twin Red Cherries & Stems", normalizedCenterX: 0.56, normalizedCenterY: 0.17, normalizedWidth: 0.40, normalizedHeight: 0.24, zIndex: 6),
                    PuzzlePieceDefinition(id: "cherry_icecream_p1", partIndex: 1, name: "Pink & Cream Swirled Scoop", normalizedCenterX: 0.50, normalizedCenterY: 0.32, normalizedWidth: 0.44, normalizedHeight: 0.34, zIndex: 4),
                    PuzzlePieceDefinition(id: "cherry_icecream_p2", partIndex: 2, name: "Left Mint Leaf Fan", normalizedCenterX: 0.27, normalizedCenterY: 0.34, normalizedWidth: 0.26, normalizedHeight: 0.26, zIndex: 2),
                    PuzzlePieceDefinition(id: "cherry_icecream_p3", partIndex: 3, name: "Right Mint Leaf Fan", normalizedCenterX: 0.73, normalizedCenterY: 0.36, normalizedWidth: 0.26, normalizedHeight: 0.26, zIndex: 2),
                    PuzzlePieceDefinition(id: "cherry_icecream_p4", partIndex: 4, name: "Upper Waffle Cone Wrapper", normalizedCenterX: 0.48, normalizedCenterY: 0.58, normalizedWidth: 0.28, normalizedHeight: 0.26, zIndex: 3),
                    PuzzlePieceDefinition(id: "cherry_icecream_p5", partIndex: 5, name: "Lower Waffle Cone Tip", normalizedCenterX: 0.46, normalizedCenterY: 0.80, normalizedWidth: 0.20, normalizedHeight: 0.28, zIndex: 1)
                ]
            ),

            // 5. Ruffle Dress Princess (Locked/IAP - shown in iphone_5.png, ipad_4.png)
            PuzzleLevel(
                id: "princess_blonde",
                index: 4,
                title: "Ruffle Dress Princess",
                subtitle: "Blonde Princess Ella",
                archetype: .blondePrincess,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "princess_blonde_p0", partIndex: 0, name: "Pink Jeweled Crown", normalizedCenterX: 0.52, normalizedCenterY: 0.11, normalizedWidth: 0.28, normalizedHeight: 0.16, zIndex: 6),
                    PuzzlePieceDefinition(id: "princess_blonde_p1", partIndex: 1, name: "Golden Blonde Hair & Face", normalizedCenterX: 0.50, normalizedCenterY: 0.26, normalizedWidth: 0.42, normalizedHeight: 0.26, zIndex: 4),
                    PuzzlePieceDefinition(id: "princess_blonde_p2", partIndex: 2, name: "Striped Bodice & Arms", normalizedCenterX: 0.50, normalizedCenterY: 0.43, normalizedWidth: 0.72, normalizedHeight: 0.20, zIndex: 3),
                    PuzzlePieceDefinition(id: "princess_blonde_p3", partIndex: 3, name: "Blue Waist Flower Belt", normalizedCenterX: 0.52, normalizedCenterY: 0.49, normalizedWidth: 0.22, normalizedHeight: 0.15, zIndex: 7),
                    PuzzlePieceDefinition(id: "princess_blonde_p4", partIndex: 4, name: "Hot-Pink Wavy Overskirt", normalizedCenterX: 0.49, normalizedCenterY: 0.62, normalizedWidth: 0.62, normalizedHeight: 0.24, zIndex: 5),
                    PuzzlePieceDefinition(id: "princess_blonde_p5", partIndex: 5, name: "Light-Pink Underskirt Ruffle", normalizedCenterX: 0.49, normalizedCenterY: 0.68, normalizedWidth: 0.64, normalizedHeight: 0.20, zIndex: 2),
                    PuzzlePieceDefinition(id: "princess_blonde_p6", partIndex: 6, name: "Legs & Blue Flower Shoes", normalizedCenterX: 0.51, normalizedCenterY: 0.84, normalizedWidth: 0.42, normalizedHeight: 0.24, zIndex: 1)
                ]
            ),

            // 6. Flower Bouquet Princess (Locked/IAP - shown in ipad_5.png)
            PuzzleLevel(
                id: "princess_flower",
                index: 5,
                title: "Flower Bouquet Princess",
                subtitle: "Princess with Meadow Daisies",
                archetype: .flowerPrincess,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "princess_flower_p0", partIndex: 0, name: "Pearl Royal Tiara", normalizedCenterX: 0.47, normalizedCenterY: 0.11, normalizedWidth: 0.28, normalizedHeight: 0.14, zIndex: 6),
                    PuzzlePieceDefinition(id: "princess_flower_p1", partIndex: 1, name: "Wavy Golden Hair", normalizedCenterX: 0.47, normalizedCenterY: 0.26, normalizedWidth: 0.48, normalizedHeight: 0.30, zIndex: 2),
                    PuzzlePieceDefinition(id: "princess_flower_p2", partIndex: 2, name: "Smiling Princess Face", normalizedCenterX: 0.47, normalizedCenterY: 0.25, normalizedWidth: 0.26, normalizedHeight: 0.22, zIndex: 5),
                    PuzzlePieceDefinition(id: "princess_flower_p3", partIndex: 3, name: "Daisy-Belted Bodice", normalizedCenterX: 0.47, normalizedCenterY: 0.43, normalizedWidth: 0.26, normalizedHeight: 0.18, zIndex: 4),
                    PuzzlePieceDefinition(id: "princess_flower_p4", partIndex: 4, name: "Left Magenta Skirt Panel", normalizedCenterX: 0.38, normalizedCenterY: 0.62, normalizedWidth: 0.28, normalizedHeight: 0.28, zIndex: 3),
                    PuzzlePieceDefinition(id: "princess_flower_p5", partIndex: 5, name: "Right Magenta Skirt Panel", normalizedCenterX: 0.56, normalizedCenterY: 0.62, normalizedWidth: 0.28, normalizedHeight: 0.28, zIndex: 3),
                    PuzzlePieceDefinition(id: "princess_flower_p6", partIndex: 6, name: "Right Arm & Flower Basket", normalizedCenterX: 0.72, normalizedCenterY: 0.48, normalizedWidth: 0.34, normalizedHeight: 0.26, zIndex: 7),
                    PuzzlePieceDefinition(id: "princess_flower_p7", partIndex: 7, name: "Left Arm & Dancing Slippers", normalizedCenterX: 0.44, normalizedCenterY: 0.78, normalizedWidth: 0.48, normalizedHeight: 0.34, zIndex: 1)
                ]
            ),

            // 7. Princess White Kitty (Locked/IAP - shown at 3:45 on wheel in iphone_1.png)
            PuzzleLevel(
                id: "royal_kitty",
                index: 6,
                title: "Princess White Kitty",
                subtitle: "Royal Kitten in Gown",
                archetype: .royalKitty,
                difficulty: .easy,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "royal_kitty_p0", partIndex: 0, name: "Golden Kitty Crown", normalizedCenterX: 0.50, normalizedCenterY: 0.15, normalizedWidth: 0.30, normalizedHeight: 0.16, zIndex: 5),
                    PuzzlePieceDefinition(id: "royal_kitty_p1", partIndex: 1, name: "White Kitty Head & Whiskers", normalizedCenterX: 0.50, normalizedCenterY: 0.33, normalizedWidth: 0.44, normalizedHeight: 0.28, zIndex: 4),
                    PuzzlePieceDefinition(id: "royal_kitty_p2", partIndex: 2, name: "White Fairy Gown & Daisy", normalizedCenterX: 0.50, normalizedCenterY: 0.60, normalizedWidth: 0.46, normalizedHeight: 0.34, zIndex: 3),
                    PuzzlePieceDefinition(id: "royal_kitty_p3", partIndex: 3, name: "Pink Royal Kitty Purse", normalizedCenterX: 0.77, normalizedCenterY: 0.56, normalizedWidth: 0.24, normalizedHeight: 0.24, zIndex: 6),
                    PuzzlePieceDefinition(id: "royal_kitty_p4", partIndex: 4, name: "Fluffy White Tail & Paws", normalizedCenterX: 0.46, normalizedCenterY: 0.82, normalizedWidth: 0.50, normalizedHeight: 0.24, zIndex: 1)
                ]
            ),

            // 8. Friendly Golden Dragon (Locked/IAP - shown at 4:45 on wheel in iphone_1.png)
            PuzzleLevel(
                id: "friendly_dragon",
                index: 7,
                title: "Friendly Golden Dragon",
                subtitle: "Guardian of the Bridge",
                archetype: .friendlyDragon,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "friendly_dragon_p0", partIndex: 0, name: "Smiling Dragon Head & Horns", normalizedCenterX: 0.28, normalizedCenterY: 0.26, normalizedWidth: 0.34, normalizedHeight: 0.26, zIndex: 6),
                    PuzzlePieceDefinition(id: "friendly_dragon_p1", partIndex: 1, name: "Left Orange Dragon Wing", normalizedCenterX: 0.36, normalizedCenterY: 0.40, normalizedWidth: 0.34, normalizedHeight: 0.26, zIndex: 2),
                    PuzzlePieceDefinition(id: "friendly_dragon_p2", partIndex: 2, name: "Right Orange Dragon Wing", normalizedCenterX: 0.68, normalizedCenterY: 0.34, normalizedWidth: 0.36, normalizedHeight: 0.28, zIndex: 2),
                    PuzzlePieceDefinition(id: "friendly_dragon_p3", partIndex: 3, name: "Scaled Golden Dragon Body", normalizedCenterX: 0.48, normalizedCenterY: 0.52, normalizedWidth: 0.38, normalizedHeight: 0.32, zIndex: 4),
                    PuzzlePieceDefinition(id: "friendly_dragon_p4", partIndex: 4, name: "Curled Spiral Dragon Tail", normalizedCenterX: 0.76, normalizedCenterY: 0.62, normalizedWidth: 0.34, normalizedHeight: 0.34, zIndex: 3),
                    PuzzlePieceDefinition(id: "friendly_dragon_p5", partIndex: 5, name: "Front Dragon Claws", normalizedCenterX: 0.34, normalizedCenterY: 0.74, normalizedWidth: 0.26, normalizedHeight: 0.24, zIndex: 5),
                    PuzzlePieceDefinition(id: "friendly_dragon_p6", partIndex: 6, name: "Hind Dragon Legs", normalizedCenterX: 0.58, normalizedCenterY: 0.78, normalizedWidth: 0.28, normalizedHeight: 0.24, zIndex: 1)
                ]
            ),

            // 9. Enchanted Rainbow Palace (Locked/IAP - shown at 6:30 on wheel in iphone_1.png)
            PuzzleLevel(
                id: "rainbow_palace",
                index: 8,
                title: "Enchanted Rainbow Palace",
                subtitle: "Turquoise & Gold Palace",
                archetype: .rainbowPalace,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "rainbow_palace_p0", partIndex: 0, name: "Golden Butterfly & Banner", normalizedCenterX: 0.50, normalizedCenterY: 0.13, normalizedWidth: 0.48, normalizedHeight: 0.18, zIndex: 7),
                    PuzzlePieceDefinition(id: "rainbow_palace_p1", partIndex: 1, name: "Left Crimson Spire & Flag", normalizedCenterX: 0.24, normalizedCenterY: 0.30, normalizedWidth: 0.22, normalizedHeight: 0.26, zIndex: 5),
                    PuzzlePieceDefinition(id: "rainbow_palace_p2", partIndex: 2, name: "Center Golden Spire & Flag", normalizedCenterX: 0.50, normalizedCenterY: 0.27, normalizedWidth: 0.24, normalizedHeight: 0.28, zIndex: 6),
                    PuzzlePieceDefinition(id: "rainbow_palace_p3", partIndex: 3, name: "Right Crimson Spire & Flag", normalizedCenterX: 0.76, normalizedCenterY: 0.30, normalizedWidth: 0.22, normalizedHeight: 0.26, zIndex: 5),
                    PuzzlePieceDefinition(id: "rainbow_palace_p4", partIndex: 4, name: "Central Turquoise Tower", normalizedCenterX: 0.50, normalizedCenterY: 0.56, normalizedWidth: 0.32, normalizedHeight: 0.42, zIndex: 4),
                    PuzzlePieceDefinition(id: "rainbow_palace_p5", partIndex: 5, name: "Left Patterned Gold Wing", normalizedCenterX: 0.23, normalizedCenterY: 0.62, normalizedWidth: 0.28, normalizedHeight: 0.36, zIndex: 2),
                    PuzzlePieceDefinition(id: "rainbow_palace_p6", partIndex: 6, name: "Right Patterned Gold Wing", normalizedCenterX: 0.77, normalizedCenterY: 0.62, normalizedWidth: 0.28, normalizedHeight: 0.36, zIndex: 2),
                    PuzzlePieceDefinition(id: "rainbow_palace_p7", partIndex: 7, name: "Crimson Striped Royal Gate", normalizedCenterX: 0.50, normalizedCenterY: 0.76, normalizedWidth: 0.34, normalizedHeight: 0.26, zIndex: 8)
                ]
            ),

            // 10. Magic Blossom & Butterfly (Locked/IAP - shown at 1:00 on wheel in iphone_1.png)
            PuzzleLevel(
                id: "butterfly_tree",
                index: 9,
                title: "Magic Blossom & Butterfly",
                subtitle: "Spiral Fairy Forest",
                archetype: .butterflyTree,
                difficulty: .easy,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "butterfly_tree_p0", partIndex: 0, name: "Pink Royal Butterfly", normalizedCenterX: 0.66, normalizedCenterY: 0.16, normalizedWidth: 0.30, normalizedHeight: 0.22, zIndex: 6),
                    PuzzlePieceDefinition(id: "butterfly_tree_p1", partIndex: 1, name: "Center Spiral Green Canopy", normalizedCenterX: 0.50, normalizedCenterY: 0.33, normalizedWidth: 0.34, normalizedHeight: 0.30, zIndex: 4),
                    PuzzlePieceDefinition(id: "butterfly_tree_p2", partIndex: 2, name: "Left Spiral Green Canopy", normalizedCenterX: 0.24, normalizedCenterY: 0.42, normalizedWidth: 0.30, normalizedHeight: 0.28, zIndex: 3),
                    PuzzlePieceDefinition(id: "butterfly_tree_p3", partIndex: 3, name: "Right Spiral Green Canopy", normalizedCenterX: 0.76, normalizedCenterY: 0.42, normalizedWidth: 0.30, normalizedHeight: 0.28, zIndex: 3),
                    PuzzlePieceDefinition(id: "butterfly_tree_p4", partIndex: 4, name: "Red Fairy Tree Trunk", normalizedCenterX: 0.50, normalizedCenterY: 0.64, normalizedWidth: 0.34, normalizedHeight: 0.38, zIndex: 2),
                    PuzzlePieceDefinition(id: "butterfly_tree_p5", partIndex: 5, name: "Meadow Blossom Base", normalizedCenterX: 0.50, normalizedCenterY: 0.84, normalizedWidth: 0.56, normalizedHeight: 0.20, zIndex: 5)
                ]
            ),

            // 11. Royal Pumpkin Carriage (Locked/IAP)
            PuzzleLevel(
                id: "pumpkin_carriage",
                index: 10,
                title: "Royal Pumpkin Carriage",
                subtitle: "Enchanted Coach to the Ball",
                archetype: .pumpkinCarriage,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p0", partIndex: 0, name: "Golden Crown Coach Roof", normalizedCenterX: 0.50, normalizedCenterY: 0.18, normalizedWidth: 0.36, normalizedHeight: 0.20, zIndex: 5),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p1", partIndex: 1, name: "Pink Pumpkin Coach Body", normalizedCenterX: 0.50, normalizedCenterY: 0.46, normalizedWidth: 0.58, normalizedHeight: 0.38, zIndex: 3),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p2", partIndex: 2, name: "Royal Window & Curtains", normalizedCenterX: 0.50, normalizedCenterY: 0.44, normalizedWidth: 0.28, normalizedHeight: 0.22, zIndex: 6),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p3", partIndex: 3, name: "Coachman Golden Lantern", normalizedCenterX: 0.80, normalizedCenterY: 0.36, normalizedWidth: 0.20, normalizedHeight: 0.22, zIndex: 7),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p4", partIndex: 4, name: "Velvet Entry Steps", normalizedCenterX: 0.50, normalizedCenterY: 0.70, normalizedWidth: 0.24, normalizedHeight: 0.18, zIndex: 4),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p5", partIndex: 5, name: "Left Golden Spoke Wheel", normalizedCenterX: 0.26, normalizedCenterY: 0.76, normalizedWidth: 0.30, normalizedHeight: 0.30, zIndex: 2),
                    PuzzlePieceDefinition(id: "pumpkin_carriage_p6", partIndex: 6, name: "Right Golden Spoke Wheel", normalizedCenterX: 0.74, normalizedCenterY: 0.76, normalizedWidth: 0.30, normalizedHeight: 0.30, zIndex: 2)
                ]
            ),

            // 12. Magic Meadow Unicorn (Locked/IAP)
            PuzzleLevel(
                id: "meadow_unicorn",
                index: 11,
                title: "Magic Meadow Unicorn",
                subtitle: "Unicorn with Rainbow Mane",
                archetype: .meadowUnicorn,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "meadow_unicorn_p0", partIndex: 0, name: "Golden Spiral Horn & Crown", normalizedCenterX: 0.74, normalizedCenterY: 0.14, normalizedWidth: 0.28, normalizedHeight: 0.22, zIndex: 7),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p1", partIndex: 1, name: "Unicorn Head & Lavender Mane", normalizedCenterX: 0.68, normalizedCenterY: 0.30, normalizedWidth: 0.38, normalizedHeight: 0.28, zIndex: 5),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p2", partIndex: 2, name: "Floral Neck Garland", normalizedCenterX: 0.60, normalizedCenterY: 0.44, normalizedWidth: 0.24, normalizedHeight: 0.20, zIndex: 6),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p3", partIndex: 3, name: "White Body & Star Flank", normalizedCenterX: 0.44, normalizedCenterY: 0.48, normalizedWidth: 0.40, normalizedHeight: 0.26, zIndex: 3),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p4", partIndex: 4, name: "Front Legs & Golden Hooves", normalizedCenterX: 0.64, normalizedCenterY: 0.72, normalizedWidth: 0.26, normalizedHeight: 0.36, zIndex: 4),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p5", partIndex: 5, name: "Hind Legs & Golden Hooves", normalizedCenterX: 0.36, normalizedCenterY: 0.72, normalizedWidth: 0.26, normalizedHeight: 0.36, zIndex: 2),
                    PuzzlePieceDefinition(id: "meadow_unicorn_p6", partIndex: 6, name: "Rainbow Flowing Tail", normalizedCenterX: 0.16, normalizedCenterY: 0.54, normalizedWidth: 0.26, normalizedHeight: 0.38, zIndex: 1)
                ]
            ),

            // 13. Crystal Tiara & Wand (Locked/IAP)
            PuzzleLevel(
                id: "royal_treasure",
                index: 12,
                title: "Crystal Tiara & Wand",
                subtitle: "Princess Royal Treasures",
                archetype: .royalTreasure,
                difficulty: .medium,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "royal_treasure_p0", partIndex: 0, name: "Pink Diamond Center Jewel", normalizedCenterX: 0.50, normalizedCenterY: 0.18, normalizedWidth: 0.26, normalizedHeight: 0.22, zIndex: 6),
                    PuzzlePieceDefinition(id: "royal_treasure_p1", partIndex: 1, name: "Golden Royal Tiara Base", normalizedCenterX: 0.50, normalizedCenterY: 0.30, normalizedWidth: 0.56, normalizedHeight: 0.24, zIndex: 4),
                    PuzzlePieceDefinition(id: "royal_treasure_p2", partIndex: 2, name: "Magic Star Fairy Wand", normalizedCenterX: 0.28, normalizedCenterY: 0.56, normalizedWidth: 0.34, normalizedHeight: 0.36, zIndex: 5),
                    PuzzlePieceDefinition(id: "royal_treasure_p3", partIndex: 3, name: "Ruby Heart Royal Locket", normalizedCenterX: 0.72, normalizedCenterY: 0.54, normalizedWidth: 0.30, normalizedHeight: 0.28, zIndex: 5),
                    PuzzlePieceDefinition(id: "royal_treasure_p4", partIndex: 4, name: "Left Crystal Glass Slipper", normalizedCenterX: 0.35, normalizedCenterY: 0.80, normalizedWidth: 0.30, normalizedHeight: 0.22, zIndex: 2),
                    PuzzlePieceDefinition(id: "royal_treasure_p5", partIndex: 5, name: "Right Crystal Glass Slipper", normalizedCenterX: 0.66, normalizedCenterY: 0.80, normalizedWidth: 0.30, normalizedHeight: 0.22, zIndex: 2)
                ]
            ),

            // 14. River Mermaid Princess (Locked/IAP)
            PuzzleLevel(
                id: "mermaid_princess",
                index: 13,
                title: "River Mermaid Princess",
                subtitle: "Princess of the Blue River",
                archetype: .mermaidPrincess,
                difficulty: .hard,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "mermaid_princess_p0", partIndex: 0, name: "Golden Seashell Tiara", normalizedCenterX: 0.50, normalizedCenterY: 0.11, normalizedWidth: 0.28, normalizedHeight: 0.15, zIndex: 7),
                    PuzzlePieceDefinition(id: "mermaid_princess_p1", partIndex: 1, name: "Flowing Coral Hair", normalizedCenterX: 0.50, normalizedCenterY: 0.26, normalizedWidth: 0.52, normalizedHeight: 0.30, zIndex: 2),
                    PuzzlePieceDefinition(id: "mermaid_princess_p2", partIndex: 2, name: "Smiling Mermaid Face", normalizedCenterX: 0.50, normalizedCenterY: 0.25, normalizedWidth: 0.28, normalizedHeight: 0.22, zIndex: 6),
                    PuzzlePieceDefinition(id: "mermaid_princess_p3", partIndex: 3, name: "Pearl Seashell Bodice", normalizedCenterX: 0.50, normalizedCenterY: 0.43, normalizedWidth: 0.32, normalizedHeight: 0.18, zIndex: 5),
                    PuzzlePieceDefinition(id: "mermaid_princess_p4", partIndex: 4, name: "Waving Mermaid Arms", normalizedCenterX: 0.50, normalizedCenterY: 0.43, normalizedWidth: 0.68, normalizedHeight: 0.20, zIndex: 3),
                    PuzzlePieceDefinition(id: "mermaid_princess_p5", partIndex: 5, name: "Upper Turquoise Scaled Tail", normalizedCenterX: 0.48, normalizedCenterY: 0.62, normalizedWidth: 0.34, normalizedHeight: 0.26, zIndex: 4),
                    PuzzlePieceDefinition(id: "mermaid_princess_p6", partIndex: 6, name: "Lower Shimmering Tail Fin", normalizedCenterX: 0.58, normalizedCenterY: 0.82, normalizedWidth: 0.42, normalizedHeight: 0.24, zIndex: 3),
                    PuzzlePieceDefinition(id: "mermaid_princess_p7", partIndex: 7, name: "Pink Starfish Friend", normalizedCenterX: 0.24, normalizedCenterY: 0.74, normalizedWidth: 0.24, normalizedHeight: 0.22, zIndex: 8)
                ]
            ),

            // 15. Sleeping Rose Princess (Locked/IAP)
            PuzzleLevel(
                id: "rose_princess",
                index: 14,
                title: "Sleeping Rose Princess",
                subtitle: "Princess of the Rose Garden",
                archetype: .rosePrincess,
                difficulty: .hard,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "rose_princess_p0", partIndex: 0, name: "Golden Rose Crown", normalizedCenterX: 0.50, normalizedCenterY: 0.11, normalizedWidth: 0.28, normalizedHeight: 0.15, zIndex: 7),
                    PuzzlePieceDefinition(id: "rose_princess_p1", partIndex: 1, name: "Long Auburn Curls", normalizedCenterX: 0.50, normalizedCenterY: 0.26, normalizedWidth: 0.48, normalizedHeight: 0.28, zIndex: 2),
                    PuzzlePieceDefinition(id: "rose_princess_p2", partIndex: 2, name: "Smiling Princess Face", normalizedCenterX: 0.50, normalizedCenterY: 0.25, normalizedWidth: 0.26, normalizedHeight: 0.22, zIndex: 6),
                    PuzzlePieceDefinition(id: "rose_princess_p3", partIndex: 3, name: "Rose Corset Bodice", normalizedCenterX: 0.50, normalizedCenterY: 0.43, normalizedWidth: 0.30, normalizedHeight: 0.20, zIndex: 5),
                    PuzzlePieceDefinition(id: "rose_princess_p4", partIndex: 4, name: "Flowing Velvet Royal Cape", normalizedCenterX: 0.50, normalizedCenterY: 0.52, normalizedWidth: 0.66, normalizedHeight: 0.36, zIndex: 1),
                    PuzzlePieceDefinition(id: "rose_princess_p5", partIndex: 5, name: "Layered Rose Gown Skirt", normalizedCenterX: 0.50, normalizedCenterY: 0.66, normalizedWidth: 0.52, normalizedHeight: 0.28, zIndex: 4),
                    PuzzlePieceDefinition(id: "rose_princess_p6", partIndex: 6, name: "Blooming Rose Bouquet", normalizedCenterX: 0.76, normalizedCenterY: 0.48, normalizedWidth: 0.26, normalizedHeight: 0.24, zIndex: 8),
                    PuzzlePieceDefinition(id: "rose_princess_p7", partIndex: 7, name: "Golden Rose Slippers", normalizedCenterX: 0.50, normalizedCenterY: 0.85, normalizedWidth: 0.36, normalizedHeight: 0.18, zIndex: 3)
                ]
            ),

            // 16. Grand Royal Ball Princess (Locked/IAP)
            PuzzleLevel(
                id: "grand_ball_princess",
                index: 15,
                title: "Grand Royal Ball Princess",
                subtitle: "Queen of the Fairy Meadow",
                archetype: .grandBallPrincess,
                difficulty: .hard,
                isFreeByDefault: false,
                pieces: [
                    PuzzlePieceDefinition(id: "grand_ball_princess_p0", partIndex: 0, name: "Diamond Star Tiara", normalizedCenterX: 0.50, normalizedCenterY: 0.10, normalizedWidth: 0.30, normalizedHeight: 0.15, zIndex: 8),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p1", partIndex: 1, name: "Royal Updo Hairstyle", normalizedCenterX: 0.50, normalizedCenterY: 0.24, normalizedWidth: 0.44, normalizedHeight: 0.24, zIndex: 3),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p2", partIndex: 2, name: "Princess Face & Ruby Necklace", normalizedCenterX: 0.50, normalizedCenterY: 0.27, normalizedWidth: 0.28, normalizedHeight: 0.22, zIndex: 7),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p3", partIndex: 3, name: "Embroidered Gold Bodice", normalizedCenterX: 0.50, normalizedCenterY: 0.43, normalizedWidth: 0.28, normalizedHeight: 0.18, zIndex: 6),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p4", partIndex: 4, name: "Left Arm & Royal Feather Fan", normalizedCenterX: 0.25, normalizedCenterY: 0.44, normalizedWidth: 0.30, normalizedHeight: 0.22, zIndex: 9),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p5", partIndex: 5, name: "Right Gloved Arm & Scepter", normalizedCenterX: 0.75, normalizedCenterY: 0.44, normalizedWidth: 0.30, normalizedHeight: 0.22, zIndex: 9),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p6", partIndex: 6, name: "Magenta Ballgown Peplum", normalizedCenterX: 0.50, normalizedCenterY: 0.57, normalizedWidth: 0.54, normalizedHeight: 0.20, zIndex: 5),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p7", partIndex: 7, name: "Golden Layered Ballgown Skirt", normalizedCenterX: 0.50, normalizedCenterY: 0.72, normalizedWidth: 0.64, normalizedHeight: 0.26, zIndex: 4),
                    PuzzlePieceDefinition(id: "grand_ball_princess_p8", partIndex: 8, name: "Crystal Dancing Shoes", normalizedCenterX: 0.50, normalizedCenterY: 0.88, normalizedWidth: 0.38, normalizedHeight: 0.16, zIndex: 2)
                ]
            )
        ]
    }
}
