import Combine
import CoreGraphics
import Foundation

/// ViewModel managing the active physics puzzle session, piece snapping, persistence, and bubble-pop surprise reward.
public final class GameplayViewModel: ObservableObject {
    @Published public let level: PuzzleLevel
    @Published public private(set) var pieceStates: [PuzzlePieceRuntimeState]
    @Published public private(set) var placedPieceIDs: Set<String>
    @Published public private(set) var isCompleted: Bool
    @Published public private(set) var isSurpriseActive: Bool
    @Published public private(set) var poppedBubblesCount: Int

    private let progressRepository: ProgressRepositoryProtocol
    private let audioService: AudioServiceProtocol

    public var totalPiecesCount: Int {
        level.pieceCount
    }

    public var placedPiecesCount: Int {
        placedPieceIDs.count
    }

    public var completionFraction: Double {
        guard totalPiecesCount > 0 else { return 1.0 }
        return Double(placedPiecesCount) / Double(totalPiecesCount)
    }

    public init(
        level: PuzzleLevel,
        progressRepository: ProgressRepositoryProtocol = ProgressRepository.shared,
        audioService: AudioServiceProtocol = AudioService.shared
    ) {
        self.level = level
        self.progressRepository = progressRepository
        self.audioService = audioService

        let savedProgress = progressRepository.loadProgress()
        let savedInProgress = savedProgress.inProgressPiecesByLevel[level.id] ?? []
        let validPieceIDs = Set(level.pieces.map(\.id))
        let restoredPlaced = savedInProgress.intersection(validPieceIDs)
        // If all pieces were already placed in a previous session, start fresh so the toddler can play again
        let initialPlaced: Set<String> = (restoredPlaced.count < level.pieces.count) ? restoredPlaced : []

        self.placedPieceIDs = initialPlaced
        self.isCompleted = false
        self.isSurpriseActive = false
        self.poppedBubblesCount = 0
        self.pieceStates = level.pieces.map { definition in
            PuzzlePieceRuntimeState(
                definition: definition,
                isPlaced: initialPlaced.contains(definition.id)
            )
        }
    }

    /// Returns whether a given piece ID has already been snapped onto the grayscale template.
    public func isPiecePlaced(_ pieceID: String) -> Bool {
        placedPieceIDs.contains(pieceID)
    }

    /// Evaluates whether a dragged piece at `currentScenePoint` is within the snap threshold of `targetScenePoint`.
    public func shouldSnapPiece(
        currentScenePoint: CGPoint,
        targetScenePoint: CGPoint,
        snapThreshold: CGFloat
    ) -> Bool {
        let distance = GeometryHelpers.distance(from: currentScenePoint, to: targetScenePoint)
        return distance <= snapThreshold
    }

    /// Marks a puzzle piece as snapped into its target slot, plays audio, saves progress, and triggers completion when all pieces are placed.
    @discardableResult
    public func markPiecePlaced(_ pieceID: String) -> Bool {
        guard level.pieces.contains(where: { $0.id == pieceID }),
              !placedPieceIDs.contains(pieceID) else {
            return false
        }

        placedPieceIDs.insert(pieceID)
        if let index = pieceStates.firstIndex(where: { $0.id == pieceID }) {
            pieceStates[index].isPlaced = true
            pieceStates[index].currentPosition = pieceStates[index].targetPosition
            pieceStates[index].currentRotationRadians = 0.0
        }

        audioService.playPieceSnap()

        if placedPieceIDs.count == level.pieceCount {
            isCompleted = true
            isSurpriseActive = true
            _ = progressRepository.markLevelCompleted(level.id)
            audioService.playVictoryFanfare()
        } else {
            _ = progressRepository.saveInProgressPieces(levelID: level.id, placedPieceIDs: placedPieceIDs)
        }
        return true
    }

    /// Records a wrong placement release when a piece is dropped outside its target snap threshold.
    public func handleWrongPlacementDrop(for pieceID: String, at position: CGPoint, rotation: CGFloat) {
        guard !placedPieceIDs.contains(pieceID) else { return }
        if let index = pieceStates.firstIndex(where: { $0.id == pieceID }) {
            pieceStates[index].currentPosition = position
            pieceStates[index].currentRotationRadians = rotation
        }
        audioService.playPieceDrop()
    }

    /// Called when the toddler taps a floating bubble/star during the completion surprise reward.
    public func recordSurpriseBubblePop() {
        poppedBubblesCount += 1
        audioService.playBubblePop(pitchIndex: poppedBubblesCount)
    }

    /// Resets the current puzzle level so all pieces drop back down into the physics meadow.
    public func resetLevel() {
        placedPieceIDs.removeAll()
        isCompleted = false
        isSurpriseActive = false
        poppedBubblesCount = 0
        pieceStates = level.pieces.map { definition in
            PuzzlePieceRuntimeState(definition: definition, isPlaced: false)
        }
        _ = progressRepository.clearInProgressPieces(levelID: level.id)
    }
}
