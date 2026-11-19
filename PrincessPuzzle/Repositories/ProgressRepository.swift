import Foundation

/// Protocol for persisting player progress, unlocked puzzles, and in-progress puzzle states.
public protocol ProgressRepositoryProtocol: AnyObject {
    func loadProgress() -> PlayerProgress
    func saveProgress(_ progress: PlayerProgress)
    func markLevelCompleted(_ levelID: String) -> PlayerProgress
    func saveInProgressPieces(levelID: String, placedPieceIDs: Set<String>) -> PlayerProgress
    func clearInProgressPieces(levelID: String) -> PlayerProgress
    func setAllPuzzlesUnlocked(_ unlocked: Bool) -> PlayerProgress
    func setSoundEnabled(_ enabled: Bool) -> PlayerProgress
    func setLastSelectedWheelIndex(_ index: Int) -> PlayerProgress
    func resetAllProgress() -> PlayerProgress
}

/// Concrete `UserDefaults`-backed implementation of `ProgressRepositoryProtocol`.
public final class ProgressRepository: ProgressRepositoryProtocol {
    public static let shared = ProgressRepository()

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let lock = NSLock()

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "com.thasmobi.physicsPuzzle05.playerProgress.v2"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func loadProgress() -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        return loadProgressUnlocked()
    }

    public func saveProgress(_ progress: PlayerProgress) {
        lock.lock()
        defer { lock.unlock() }
        saveProgressUnlocked(progress)
    }

    @discardableResult
    public func markLevelCompleted(_ levelID: String) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        let isNewCompletion = !current.completedLevelIDs.contains(levelID)
        current.completedLevelIDs.insert(levelID)
        current.inProgressPiecesByLevel.removeValue(forKey: levelID)
        if isNewCompletion {
            current.totalStarsEarned += 3
        } else {
            current.totalStarsEarned += 1
        }
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func saveInProgressPieces(levelID: String, placedPieceIDs: Set<String>) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        if placedPieceIDs.isEmpty {
            current.inProgressPiecesByLevel.removeValue(forKey: levelID)
        } else {
            current.inProgressPiecesByLevel[levelID] = placedPieceIDs
        }
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func clearInProgressPieces(levelID: String) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        current.inProgressPiecesByLevel.removeValue(forKey: levelID)
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func setAllPuzzlesUnlocked(_ unlocked: Bool) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        current.isAllPuzzlesUnlocked = unlocked
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func setSoundEnabled(_ enabled: Bool) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        current.isSoundEnabled = enabled
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func setLastSelectedWheelIndex(_ index: Int) -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        var current = loadProgressUnlocked()
        current.lastSelectedWheelIndex = index
        saveProgressUnlocked(current)
        return current
    }

    @discardableResult
    public func resetAllProgress() -> PlayerProgress {
        lock.lock()
        defer { lock.unlock() }
        let fresh = PlayerProgress()
        saveProgressUnlocked(fresh)
        return fresh
    }

    // MARK: - Private Unlocked Helpers

    private func loadProgressUnlocked() -> PlayerProgress {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) else {
            return PlayerProgress()
        }
        return decoded
    }

    private func saveProgressUnlocked(_ progress: PlayerProgress) {
        guard let encoded = try? JSONEncoder().encode(progress) else { return }
        userDefaults.set(encoded, forKey: storageKey)
    }
}
