import Combine
import Foundation

/// Top-level route state for the application.
public enum AppScreenRoute: Equatable {
    case planetWheel
    case puzzleGameplay(PuzzleLevel)
}

/// Root ViewModel coordinating screen navigation, audio toggle, StoreKit unlocking, and level progression.
public final class AppViewModel: ObservableObject {
    @Published public private(set) var currentRoute: AppScreenRoute = .planetWheel
    @Published public private(set) var isSoundEnabled: Bool
    @Published public let wheelViewModel: WheelViewModel
    @Published public let storeViewModel: StoreViewModel
    @Published public private(set) var activeGameplayViewModel: GameplayViewModel?

    private let progressRepository: ProgressRepositoryProtocol
    private let audioService: AudioServiceProtocol

    public init(
        progressRepository: ProgressRepositoryProtocol = ProgressRepository.shared,
        puzzleRepository: PuzzleRepositoryProtocol = PuzzleRepository.shared,
        audioService: AudioServiceProtocol = AudioService.shared,
        storeService: StoreServiceProtocol = StoreService.shared
    ) {
        self.progressRepository = progressRepository
        self.audioService = audioService

        let initialProgress = progressRepository.loadProgress()
        self.isSoundEnabled = initialProgress.isSoundEnabled
        audioService.isSoundEnabled = initialProgress.isSoundEnabled

        let wheelVM = WheelViewModel(
            puzzleRepository: puzzleRepository,
            progressRepository: progressRepository,
            audioService: audioService
        )
        let storeVM = StoreViewModel(
            storeService: storeService,
            progressRepository: progressRepository
        )
        self.wheelViewModel = wheelVM
        self.storeViewModel = storeVM

        storeVM.setUnlockCompletionHandler { [weak wheelVM] in
            wheelVM?.refreshFromProgress()
        }
    }

    /// Selects a puzzle from the Rotating Planet Carousel.
    /// If the puzzle is unlocked, enters the Physics Puzzle Gameplay scene; otherwise presents the Kid-Safe Parental Gate.
    public func selectPuzzle(_ level: PuzzleLevel) {
        wheelViewModel.focusLevel(at: level.index)
        if wheelViewModel.isLevelUnlocked(level) {
            let gameplayVM = GameplayViewModel(
                level: level,
                progressRepository: progressRepository,
                audioService: audioService
            )
            activeGameplayViewModel = gameplayVM
            currentRoute = .puzzleGameplay(level)
        } else {
            storeViewModel.presentParentalGate()
        }
    }

    /// Returns from the Gameplay scene back to the Rotating Planet Carousel.
    /// If the puzzle was completed, refreshes badges and rotates the planet wheel to the next puzzle.
    public func returnToWheel(advanceToNextIfCompleted: Bool = true) {
        let wasCompleted = activeGameplayViewModel?.isCompleted ?? false
        let currentIndex = activeGameplayViewModel?.level.index ?? wheelViewModel.activeLevelIndex

        wheelViewModel.refreshFromProgress()
        activeGameplayViewModel = nil
        currentRoute = .planetWheel

        if wasCompleted && advanceToNextIfCompleted {
            let nextIndex = (currentIndex + 1) % max(1, wheelViewModel.levels.count)
            wheelViewModel.focusLevel(at: nextIndex)
        }
    }

    /// Advances directly to the next unlocked puzzle from the victory surprise screen.
    public func advanceToNextPuzzle() {
        let currentIndex = activeGameplayViewModel?.level.index ?? wheelViewModel.activeLevelIndex
        wheelViewModel.refreshFromProgress()
        let total = max(1, wheelViewModel.levels.count)
        let nextIndex = (currentIndex + 1) % total
        guard let nextLevel = wheelViewModel.levels.indices.contains(nextIndex) ? wheelViewModel.levels[nextIndex] : nil else {
            returnToWheel(advanceToNextIfCompleted: false)
            return
        }

        if wheelViewModel.isLevelUnlocked(nextLevel) {
            selectPuzzle(nextLevel)
        } else {
            returnToWheel(advanceToNextIfCompleted: false)
            wheelViewModel.focusLevel(at: nextLevel.index)
            storeViewModel.presentParentalGate()
        }
    }

    /// Toggles sound effects on/off and persists the setting.
    public func toggleSound() {
        isSoundEnabled.toggle()
        audioService.isSoundEnabled = isSoundEnabled
        _ = progressRepository.setSoundEnabled(isSoundEnabled)
        if isSoundEnabled {
            audioService.playPiecePickup()
        }
    }
}
