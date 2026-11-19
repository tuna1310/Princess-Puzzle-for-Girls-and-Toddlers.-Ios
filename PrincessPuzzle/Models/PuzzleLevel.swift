import CoreGraphics
import Foundation

/// Difficulty tier for the 16 puzzles in the application (ages 1-6).
public enum PuzzleDifficulty: String, Codable, CaseIterable, Sendable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    public var ageRangeText: String {
        switch self {
        case .easy:
            return "Ages 1–3"
        case .medium:
            return "Ages 3–5"
        case .hard:
            return "Ages 4–6"
        }
    }
}

/// Visual theme archetype used by `PuzzleIllustrationRenderer` to draw each puzzle and its anatomical parts.
public enum PuzzleThemeArchetype: String, Codable, CaseIterable, Sendable {
    case pinkCastle
    case brunettePrincess
    case royalPony
    case cherryIceCream
    case blondePrincess
    case flowerPrincess
    case royalKitty
    case friendlyDragon
    case rainbowPalace
    case butterflyTree
    case pumpkinCarriage
    case meadowUnicorn
    case royalTreasure
    case mermaidPrincess
    case rosePrincess
    case grandBallPrincess
}

/// Represents one of the 16 puzzle levels in "Princess Puzzle for Girls and Toddlers".
public struct PuzzleLevel: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let index: Int
    public let title: String
    public let subtitle: String
    public let archetype: PuzzleThemeArchetype
    public let difficulty: PuzzleDifficulty
    public let isFreeByDefault: Bool
    public let pieces: [PuzzlePieceDefinition]

    public var pieceCount: Int {
        pieces.count
    }

    public init(
        id: String,
        index: Int,
        title: String,
        subtitle: String,
        archetype: PuzzleThemeArchetype,
        difficulty: PuzzleDifficulty,
        isFreeByDefault: Bool,
        pieces: [PuzzlePieceDefinition]
    ) {
        self.id = id
        self.index = index
        self.title = title
        self.subtitle = subtitle
        self.archetype = archetype
        self.difficulty = difficulty
        self.isFreeByDefault = isFreeByDefault
        self.pieces = pieces
    }
}
