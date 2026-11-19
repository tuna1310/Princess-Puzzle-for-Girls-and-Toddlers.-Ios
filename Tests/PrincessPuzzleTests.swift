import CoreGraphics
import SpriteKit
import UIKit
import XCTest
@testable import PrincessPuzzle

final class PrincessPuzzleTests: XCTestCase {
    private var testDefaults: UserDefaults!
    private var progressRepo: ProgressRepository!
    private var mockAudio: MockAudioService!
    private var mockStore: MockStoreService!

    override func setUp() {
        super.setUp()
        let suiteName = "com.thasmobi.physicsPuzzle05.tests.\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: suiteName)
        progressRepo = ProgressRepository(userDefaults: testDefaults, storageKey: "test_progress")
        mockAudio = MockAudioService()
        mockStore = MockStoreService()
    }

    override func tearDown() {
        testDefaults = nil
        progressRepo = nil
        mockAudio = nil
        mockStore = nil
        super.tearDown()
    }

    // MARK: - 1. Catalog & 16 Puzzles Verification

    func testPuzzleCatalogHas16LevelsWithValidPieces() {
        let levels = PuzzleRepository.shared.allLevels()
        XCTAssertEqual(levels.count, 16, "Reference app must contain exactly 16 puzzles.")

        let freeLevels = levels.filter(\.isFreeByDefault)
        XCTAssertEqual(freeLevels.count, 4, "The first 4 puzzles should be free of charge.")
        XCTAssertEqual(freeLevels.map(\.id), ["castle_pink", "princess_brunette", "royal_pony", "cherry_icecream"])

        for (expectedIndex, level) in levels.enumerated() {
            XCTAssertEqual(level.index, expectedIndex)
            XCTAssertGreaterThanOrEqual(level.pieceCount, 5)
            XCTAssertLessThanOrEqual(level.pieceCount, 9)

            for piece in level.pieces {
                XCTAssertTrue((0.05...0.95).contains(piece.normalizedCenterX), "Invalid centerX in \(piece.id)")
                XCTAssertTrue((0.05...0.95).contains(piece.normalizedCenterY), "Invalid centerY in \(piece.id)")
                XCTAssertTrue((0.10...0.85).contains(piece.normalizedWidth), "Invalid width in \(piece.id)")
                XCTAssertTrue((0.10...0.85).contains(piece.normalizedHeight), "Invalid height in \(piece.id)")
            }
        }
    }

    // MARK: - 2. Rotating Planet Carousel Mechanics

    func testPlanetWheelRotationAndSnap() {
        let wheelVM = WheelViewModel(
            puzzleRepository: PuzzleRepository.shared,
            progressRepository: progressRepo,
            audioService: mockAudio
        )

        XCTAssertEqual(wheelVM.activeLevelIndex, 0)
        XCTAssertEqual(wheelVM.activeLevel?.id, "castle_pink")

        // Top-Right counter-clockwise arrow advances to index 1
        wheelVM.rotateCounterClockwise()
        XCTAssertEqual(wheelVM.activeLevelIndex, 1)
        XCTAssertEqual(wheelVM.activeLevel?.id, "princess_brunette")
        XCTAssertGreaterThan(mockAudio.wheelTickCount, 0)

        // Top-Left clockwise arrow rotates back to index 0, then wraps to index 15
        wheelVM.rotateClockwise()
        XCTAssertEqual(wheelVM.activeLevelIndex, 0)
        wheelVM.rotateClockwise()
        XCTAssertEqual(wheelVM.activeLevelIndex, 15)
        XCTAssertEqual(wheelVM.activeLevel?.id, "grand_ball_princess")

        // Partial drag followed by snapToNearestLevel
        wheelVM.focusLevel(at: 2)
        wheelVM.applyDragRotation(deltaRadians: 0.08)
        wheelVM.snapToNearestLevel()
        XCTAssertEqual(wheelVM.activeLevelIndex, 2)
    }

    // MARK: - 3. Gameplay Snapping, Wrong Drop & Victory Surprise

    func testGameplaySnapWrongDropAndCompletion() {
        guard let ponyLevel = PuzzleRepository.shared.level(withID: "royal_pony") else {
            XCTFail("Missing royal_pony level")
            return
        }

        let gameplayVM = GameplayViewModel(
            level: ponyLevel,
            progressRepository: progressRepo,
            audioService: mockAudio
        )

        XCTAssertEqual(gameplayVM.totalPiecesCount, 6)
        XCTAssertEqual(gameplayVM.placedPiecesCount, 0)
        XCTAssertFalse(gameplayVM.isCompleted)

        // Verify snap distance calculation
        let target = CGPoint(x: 200, y: 400)
        XCTAssertTrue(gameplayVM.shouldSnapPiece(currentScenePoint: CGPoint(x: 225, y: 418), targetScenePoint: target, snapThreshold: 55))
        XCTAssertFalse(gameplayVM.shouldSnapPiece(currentScenePoint: CGPoint(x: 310, y: 200), targetScenePoint: target, snapThreshold: 55))

        // Wrong placement drop
        let firstPieceID = ponyLevel.pieces[0].id
        gameplayVM.handleWrongPlacementDrop(for: firstPieceID, at: CGPoint(x: 120, y: 90), rotation: 0.35)
        XCTAssertEqual(mockAudio.dropCount, 1)
        XCTAssertFalse(gameplayVM.isPiecePlaced(firstPieceID))

        // Place first 5 pieces and verify mid-game persistence
        for piece in ponyLevel.pieces.dropLast() {
            XCTAssertTrue(gameplayVM.markPiecePlaced(piece.id))
        }
        XCTAssertEqual(gameplayVM.placedPiecesCount, 5)
        XCTAssertFalse(gameplayVM.isCompleted)

        // Simulate app restart mid-puzzle: new GameplayViewModel restores the 5 placed pieces
        let restoredVM = GameplayViewModel(
            level: ponyLevel,
            progressRepository: progressRepo,
            audioService: mockAudio
        )
        XCTAssertEqual(restoredVM.placedPiecesCount, 5)

        // Place the final 6th piece -> triggers completion & interactive bubble-pop surprise!
        if let lastPiece = ponyLevel.pieces.last {
            XCTAssertTrue(restoredVM.markPiecePlaced(lastPiece.id))
        }
        XCTAssertTrue(restoredVM.isCompleted)
        XCTAssertTrue(restoredVM.isSurpriseActive)
        XCTAssertEqual(mockAudio.victoryFanfareCount, 1)
        XCTAssertTrue(progressRepo.loadProgress().completedLevelIDs.contains("royal_pony"))

        // Pop 3 surprise bubbles
        restoredVM.recordSurpriseBubblePop()
        restoredVM.recordSurpriseBubblePop()
        restoredVM.recordSurpriseBubblePop()
        XCTAssertEqual(restoredVM.poppedBubblesCount, 3)
        XCTAssertEqual(mockAudio.bubblePopCount, 3)
    }

    // MARK: - 4. Progress Persistence & State Restoration

    func testProgressRepositoryPersistenceAndRestore() {
        _ = progressRepo.markLevelCompleted("castle_pink")
        _ = progressRepo.setLastSelectedWheelIndex(3)
        _ = progressRepo.setSoundEnabled(false)
        _ = progressRepo.setAllPuzzlesUnlocked(true)

        let loaded = progressRepo.loadProgress()
        XCTAssertTrue(loaded.completedLevelIDs.contains("castle_pink"))
        XCTAssertEqual(loaded.lastSelectedWheelIndex, 3)
        XCTAssertFalse(loaded.isSoundEnabled)
        XCTAssertTrue(loaded.isAllPuzzlesUnlocked)
        XCTAssertEqual(loaded.totalStarsEarned, 3)
    }

    // MARK: - 5. Kid-Safe Parental Gate & StoreKit 2 Unlock Flow

    @MainActor
    func testParentalGateAndStoreUnlockFlow() async {
        var didNotifyUnlock = false
        let storeVM = StoreViewModel(
            storeService: mockStore,
            progressRepository: progressRepo,
            onUnlockCompleted: {
                didNotifyUnlock = true
            }
        )

        storeVM.presentParentalGate()
        XCTAssertTrue(storeVM.isParentalGatePresented)
        XCTAssertFalse(storeVM.isStoreSheetPresented)

        // Child taps wrong answer -> gate stays closed and regenerates challenge
        let wrongAnswer = storeVM.currentChallenge.correctAnswer + 99
        XCTAssertFalse(storeVM.submitParentalAnswer(wrongAnswer))
        XCTAssertFalse(storeVM.isStoreSheetPresented)
        XCTAssertNotNil(storeVM.parentalGateErrorMessage)

        // Parent taps correct answer -> opens StoreKit sheet
        let rightAnswer = storeVM.currentChallenge.correctAnswer
        XCTAssertTrue(storeVM.submitParentalAnswer(rightAnswer))
        XCTAssertFalse(storeVM.isParentalGatePresented)
        XCTAssertTrue(storeVM.isStoreSheetPresented)

        // Execute StoreKit Unlock All purchase ($2.99)
        await storeVM.purchaseUnlockAll()
        XCTAssertTrue(storeVM.isAllUnlocked)
        XCTAssertTrue(didNotifyUnlock)
        XCTAssertTrue(progressRepo.loadProgress().isAllPuzzlesUnlocked)
    }

    // MARK: - 6. AppViewModel Navigation & Locked Puzzle Redirect

    func testAppNavigationAndLockedPuzzleRedirect() {
        let appVM = AppViewModel(
            progressRepository: progressRepo,
            puzzleRepository: PuzzleRepository.shared,
            audioService: mockAudio,
            storeService: mockStore
        )

        let levels = appVM.wheelViewModel.levels
        let freeLevel = levels[0]   // Pink Fairy Castle (Free)
        let lockedLevel = levels[4] // Ruffle Dress Princess (Locked until IAP)

        // Selecting a locked level opens the Parental Gate instead of gameplay
        appVM.selectPuzzle(lockedLevel)
        XCTAssertEqual(appVM.currentRoute, .planetWheel)
        XCTAssertTrue(appVM.storeViewModel.isParentalGatePresented)
        appVM.storeViewModel.dismissModals()

        // Selecting a free level opens gameplay
        appVM.selectPuzzle(freeLevel)
        XCTAssertEqual(appVM.currentRoute, .puzzleGameplay(freeLevel))
        XCTAssertNotNil(appVM.activeGameplayViewModel)

        // Complete all pieces in freeLevel and return to wheel -> auto-focuses next puzzle (index 1)
        for piece in freeLevel.pieces {
            _ = appVM.activeGameplayViewModel?.markPiecePlaced(piece.id)
        }
        appVM.returnToWheel(advanceToNextIfCompleted: true)
        XCTAssertEqual(appVM.currentRoute, .planetWheel)
        XCTAssertEqual(appVM.wheelViewModel.activeLevelIndex, 1)
    }

    // MARK: - 7. CoreGraphics Vector Illustration & Grayscale Silhouette Renderer

    func testIllustrationRendererColorAndGrayscale() {
        let levels = PuzzleRepository.shared.allLevels()
        for level in levels {
            let fullColor = PuzzleIllustrationRenderer.shared.renderFullIllustration(
                for: level,
                size: CGSize(width: 160, height: 180),
                grayscale: false
            )
            let fullGray = PuzzleIllustrationRenderer.shared.renderFullIllustration(
                for: level,
                size: CGSize(width: 160, height: 180),
                grayscale: true
            )
            XCTAssertGreaterThan(fullColor.size.width, 0)
            XCTAssertGreaterThan(fullGray.size.height, 0)
        }

        if let firstLevel = levels.first, let firstPiece = firstLevel.pieces.first {
            let pieceImg = PuzzleIllustrationRenderer.shared.renderPieceImage(
                for: firstLevel,
                piece: firstPiece,
                canvasSize: CGSize(width: 240, height: 270),
                grayscale: false
            )
            XCTAssertGreaterThan(pieceImg.size.width, 20)
            XCTAssertGreaterThan(pieceImg.size.height, 20)
        }
    }

    // MARK: - 8. Procedural WAV Audio Synthesizer Verification

    func testAudioSynthesizerProducesValidRIFFWAVHeader() {
        let wavData = AudioService.generateToneSequenceWAV(
            notes: [(frequency: 523.25, duration: 0.05)],
            amplitude: 0.4
        )
        XCTAssertGreaterThan(wavData.count, 44)
        let riffHeader = String(data: wavData.subdata(in: 0..<4), encoding: .ascii)
        let waveHeader = String(data: wavData.subdata(in: 8..<12), encoding: .ascii)
        XCTAssertEqual(riffHeader, "RIFF")
        XCTAssertEqual(waveHeader, "WAVE")
    }

    // MARK: - 9. SpriteKit 2D Physics Scene Lifecycle

    func testSpriteKitPhysicsSceneBuildsSilhouetteAndPieces() {
        guard let level = PuzzleRepository.shared.level(withID: "princess_brunette") else {
            XCTFail("Missing princess_brunette level")
            return
        }
        let vm = GameplayViewModel(level: level, progressRepository: progressRepo, audioService: mockAudio)
        let scene = PuzzlePhysicsScene(size: CGSize(width: 392, height: 696), viewModel: vm, audioService: mockAudio)
        scene.rebuildSceneIfNeeded(force: true)

        XCTAssertNotNil(scene.physicsBody, "Scene must have an edge-loop boundary physics body.")
        let allPieceNodes = scene.children.flatMap { $0.children }.compactMap { $0 as? PuzzlePieceSpriteNode }
        XCTAssertEqual(allPieceNodes.count, level.pieceCount)
        for pieceNode in allPieceNodes {
            XCTAssertFalse(pieceNode.isSnappedAndLocked)
            XCTAssertNotNil(pieceNode.physicsBody)
        }
    }
}

// MARK: - Test Doubles

private final class MockAudioService: AudioServiceProtocol {
    var isSoundEnabled: Bool = true
    var wheelTickCount = 0
    var pickupCount = 0
    var snapCount = 0
    var dropCount = 0
    var bubblePopCount = 0
    var victoryFanfareCount = 0

    func playWheelRotateTick() { wheelTickCount += 1 }
    func playPiecePickup() { pickupCount += 1 }
    func playPieceSnap() { snapCount += 1 }
    func playPieceDrop() { dropCount += 1 }
    func playBubblePop(pitchIndex: Int) { bubblePopCount += 1 }
    func playVictoryFanfare() { victoryFanfareCount += 1 }
}

private final class MockStoreService: StoreServiceProtocol {
    let unlockAllProductID: String = "com.thasmobi.physicsPuzzle05.unlockAll"
    let displayTitle: String = "Unlock all puzzles"
    let displayPrice: String = "$2.99"

    func loadProducts() async {}
    func purchaseUnlockAll() async -> StorePurchaseOutcome {
        .unlocked(productID: unlockAllProductID, displayPrice: displayPrice)
    }
    func restorePurchases() async -> StorePurchaseOutcome {
        .unlocked(productID: unlockAllProductID, displayPrice: displayPrice)
    }
}
