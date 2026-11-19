import Foundation

/// Persisted player progress, unlocked entitlement, audio preferences, and in-progress puzzle state.
public struct PlayerProgress: Codable, Equatable, Sendable {
    public var completedLevelIDs: Set<String>
    public var isAllPuzzlesUnlocked: Bool
    public var isSoundEnabled: Bool
    public var lastSelectedWheelIndex: Int
    public var totalStarsEarned: Int
    /// Maps `levelID` -> Set of `pieceID`s already snapped in an unfinished session.
    public var inProgressPiecesByLevel: [String: Set<String>]

    public init(
        completedLevelIDs: Set<String> = [],
        isAllPuzzlesUnlocked: Bool = false,
        isSoundEnabled: Bool = true,
        lastSelectedWheelIndex: Int = 0,
        totalStarsEarned: Int = 0,
        inProgressPiecesByLevel: [String: Set<String>] = [:]
    ) {
        self.completedLevelIDs = completedLevelIDs
        self.isAllPuzzlesUnlocked = isAllPuzzlesUnlocked
        self.isSoundEnabled = isSoundEnabled
        self.lastSelectedWheelIndex = lastSelectedWheelIndex
        self.totalStarsEarned = totalStarsEarned
        self.inProgressPiecesByLevel = inProgressPiecesByLevel
    }
}
