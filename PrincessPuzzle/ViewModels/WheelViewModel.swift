import Combine
import CoreGraphics
import Foundation

/// ViewModel managing the Rotating Fairy-Tale Planet Carousel level selector (`iphone_1.png`, `ipad_3.png`).
public final class WheelViewModel: ObservableObject {
    @Published public private(set) var levels: [PuzzleLevel]
    @Published public var wheelRotationRadians: Double
    @Published public private(set) var activeLevelIndex: Int
    @Published public private(set) var completedLevelIDs: Set<String>
    @Published public private(set) var isAllPuzzlesUnlocked: Bool
    @Published public private(set) var totalStarsEarned: Int

    private let puzzleRepository: PuzzleRepositoryProtocol
    private let progressRepository: ProgressRepositoryProtocol
    private let audioService: AudioServiceProtocol

    public var stepAngleRadians: Double {
        guard !levels.isEmpty else { return .pi / 8.0 }
        return (Double.pi * 2.0) / Double(levels.count)
    }

    public var activeLevel: PuzzleLevel? {
        guard levels.indices.contains(activeLevelIndex) else { return levels.first }
        return levels[activeLevelIndex]
    }

    public init(
        puzzleRepository: PuzzleRepositoryProtocol = PuzzleRepository.shared,
        progressRepository: ProgressRepositoryProtocol = ProgressRepository.shared,
        audioService: AudioServiceProtocol = AudioService.shared
    ) {
        self.puzzleRepository = puzzleRepository
        self.progressRepository = progressRepository
        self.audioService = audioService

        let loadedLevels = puzzleRepository.allLevels()
        let progress = progressRepository.loadProgress()
        let clampedIndex = loadedLevels.isEmpty ? 0 : min(max(0, progress.lastSelectedWheelIndex), loadedLevels.count - 1)
        let step = loadedLevels.isEmpty ? (.pi / 8.0) : ((Double.pi * 2.0) / Double(loadedLevels.count))

        self.levels = loadedLevels
        self.activeLevelIndex = clampedIndex
        self.wheelRotationRadians = -Double(clampedIndex) * step
        self.completedLevelIDs = progress.completedLevelIDs
        self.isAllPuzzlesUnlocked = progress.isAllPuzzlesUnlocked
        self.totalStarsEarned = progress.totalStarsEarned
    }

    /// Returns whether a puzzle level is unlocked for play (Levels 1-4 are free; 5-16 unlock via IAP).
    public func isLevelUnlocked(_ level: PuzzleLevel) -> Bool {
        level.isFreeByDefault || isAllPuzzlesUnlocked
    }

    /// Returns whether a puzzle level has been completed at least once.
    public func isLevelCompleted(_ level: PuzzleLevel) -> Bool {
        completedLevelIDs.contains(level.id)
    }

    /// Top-Left Blue Curved Arrow (`↷`): rotates the planet wheel clockwise by one puzzle slot.
    public func rotateClockwise() {
        guard !levels.isEmpty else { return }
        audioService.playWheelRotateTick()
        wheelRotationRadians += stepAngleRadians
        syncActiveIndexFromRotation()
    }

    /// Top-Right Blue Curved Arrow (`↶`): rotates the planet wheel counter-clockwise by one puzzle slot.
    public func rotateCounterClockwise() {
        guard !levels.isEmpty else { return }
        audioService.playWheelRotateTick()
        wheelRotationRadians -= stepAngleRadians
        syncActiveIndexFromRotation()
    }

    /// Rotates smoothly to focus a specific puzzle index at the 12-o'clock top indicator line.
    public func focusLevel(at index: Int) {
        guard !levels.isEmpty else { return }
        let safeIndex = ((index % levels.count) + levels.count) % levels.count
        let targetRotation = -Double(safeIndex) * stepAngleRadians
        let delta = GeometryHelpers.shortestAngularDelta(from: wheelRotationRadians, to: targetRotation)
        wheelRotationRadians += delta
        activeLevelIndex = safeIndex
        _ = progressRepository.setLastSelectedWheelIndex(safeIndex)
    }

    /// Applies an incremental drag delta in radians while the user spins the planet wheel by touch.
    public func applyDragRotation(deltaRadians: Double) {
        wheelRotationRadians += deltaRadians
    }

    /// Snaps the wheel rotation to the nearest puzzle stop when a touch drag gesture ends.
    public func snapToNearestLevel() {
        guard !levels.isEmpty else { return }
        let nearestIndex = GeometryHelpers.activeIndexOnWheel(
            rotationRadians: wheelRotationRadians,
            totalCount: levels.count
        )
        focusLevel(at: nearestIndex)
        audioService.playWheelRotateTick()
    }

    /// Reloads persisted progress and unlock status from `ProgressRepository`.
    public func refreshFromProgress() {
        let progress = progressRepository.loadProgress()
        completedLevelIDs = progress.completedLevelIDs
        isAllPuzzlesUnlocked = progress.isAllPuzzlesUnlocked
        totalStarsEarned = progress.totalStarsEarned
    }

    private func syncActiveIndexFromRotation() {
        let index = GeometryHelpers.activeIndexOnWheel(
            rotationRadians: wheelRotationRadians,
            totalCount: levels.count
        )
        activeLevelIndex = index
        _ = progressRepository.setLastSelectedWheelIndex(index)
    }
}
