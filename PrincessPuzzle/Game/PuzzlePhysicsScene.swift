import SpriteKit
import UIKit

/// Main 2D Physics Puzzle Scene (`SpriteKit`) reproducing the exact gameplay of `com.thasmobi.physicsPuzzle05`:
/// - Upper-middle grayscale target silhouette board (`ipad_5.png`) where snapped parts illuminate in full vibrant color (`iphone_2..5.png`).
/// - Lower meadow physics floor with 2D gravity (`dy = -6.5`), rigid-body collisions, friction, and natural tilted resting angles.
/// - Smooth finger drag with auto-righting (`zRotation -> 0`), magnetic snap-to-slot, wrong-placement gravity drop, and interactive bubble-pop victory reward.
public final class PuzzlePhysicsScene: SKScene, SKPhysicsContactDelegate {
    public weak var viewModel: GameplayViewModel?
    private let audioService: AudioServiceProtocol

    private let boardContainerNode = SKNode()
    private var grayscalePartNodes: [String: SKSpriteNode] = [:]
    private var pieceNodes: [String: PuzzlePieceSpriteNode] = [:]
    private var activeDraggedPiece: PuzzlePieceSpriteNode?
    private var dragTouchOffset: CGPoint = .zero
    private var hasConfiguredLayout: Bool = false
    private var lastConfiguredSize: CGSize = .zero

    public init(
        size: CGSize,
        viewModel: GameplayViewModel,
        audioService: AudioServiceProtocol = AudioService.shared
    ) {
        self.viewModel = viewModel
        self.audioService = audioService
        super.init(size: size)
        self.scaleMode = .resizeFill
        self.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.allowsTransparency = true
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -6.5)
        physicsWorld.contactDelegate = self
        rebuildSceneIfNeeded(force: true)
    }

    public override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if abs(size.width - lastConfiguredSize.width) > 4 || abs(size.height - lastConfiguredSize.height) > 4 {
            rebuildSceneIfNeeded(force: true)
        }
    }

    // MARK: - Scene Layout & Physics World Setup

    public func rebuildSceneIfNeeded(force: Bool = false) {
        guard size.width > 80, size.height > 80, let vm = viewModel else { return }
        if hasConfiguredLayout && !force { return }
        hasConfiguredLayout = true
        lastConfiguredSize = size

        removeAllChildren()
        removeAllActions()
        grayscalePartNodes.removeAll()
        pieceNodes.removeAll()
        activeDraggedPiece = nil

        configurePhysicsBoundaries()
        buildTargetSilhouetteAndPieces(for: vm)
    }

    private func configurePhysicsBoundaries() {
        let playableRect = CGRect(
            x: 10,
            y: 22,
            width: max(60, size.width - 20),
            height: max(60, size.height - 34)
        )
        let boundaryBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        boundaryBody.friction = 0.55
        boundaryBody.restitution = 0.22
        boundaryBody.categoryBitMask = PhysicsCategory.boundary
        boundaryBody.collisionBitMask = PhysicsCategory.puzzlePiece
        self.physicsBody = boundaryBody

        // Subtle invisible meadow floor ledges along the river/path so pieces rest at varied heights
        // just like in iphone_2..5.png and ipad_1,2,4,5.png
        let ledgeLeft = SKNode()
        ledgeLeft.position = CGPoint(x: size.width * 0.25, y: size.height * 0.08)
        let leftBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: -size.width * 0.22, y: 12),
            to: CGPoint(x: size.width * 0.18, y: -6)
        )
        leftBody.categoryBitMask = PhysicsCategory.terrainLedge
        leftBody.friction = 0.55
        ledgeLeft.physicsBody = leftBody
        addChild(ledgeLeft)
    }

    private func buildTargetSilhouetteAndPieces(for vm: GameplayViewModel) {
        let isPad = size.width >= 600
        let boardWidth = min(size.width * (isPad ? 0.56 : 0.72), isPad ? 410 : 280)
        let boardHeight = boardWidth * 1.10
        let boardSize = CGSize(width: boardWidth, height: boardHeight)
        // Upper-middle center position matching iphone_2..5.png and ipad_1,2,4,5.png
        let boardCenter = CGPoint(x: size.width * 0.50, y: size.height * 0.67)

        boardContainerNode.removeAllChildren()
        boardContainerNode.position = .zero
        addChild(boardContainerNode)

        let sortedPieces = vm.level.pieces.sorted { $0.zIndex < $1.zIndex }

        for (spawnIndex, pieceDef) in sortedPieces.enumerated() {
            // Convert normalized top-left UIKit coordinates to bottom-left SpriteKit scene coordinates
            let targetX = (boardCenter.x - boardSize.width / 2.0) + pieceDef.normalizedCenterX * boardSize.width
            let targetY = (boardCenter.y + boardSize.height / 2.0) - pieceDef.normalizedCenterY * boardSize.height
            let targetPoint = CGPoint(x: targetX, y: targetY)
            let pieceSize = CGSize(
                width: max(28, pieceDef.normalizedWidth * boardSize.width),
                height: max(28, pieceDef.normalizedHeight * boardSize.height)
            )

            // 1. Grayscale silhouette node on the upper target board
            let grayImage = PuzzleIllustrationRenderer.shared.renderPieceImage(
                for: vm.level,
                piece: pieceDef,
                canvasSize: boardSize,
                grayscale: true
            )
            let grayNode = SKSpriteNode(texture: SKTexture(image: grayImage), size: pieceSize)
            grayNode.position = targetPoint
            grayNode.zPosition = CGFloat(5 + pieceDef.zIndex)
            grayNode.alpha = vm.isPiecePlaced(pieceDef.id) ? 0.0 : 0.92
            boardContainerNode.addChild(grayNode)
            grayscalePartNodes[pieceDef.id] = grayNode

            // 2. Full-color physics puzzle piece node
            let colorImage = PuzzleIllustrationRenderer.shared.renderPieceImage(
                for: vm.level,
                piece: pieceDef,
                canvasSize: boardSize,
                grayscale: false
            )
            let pieceNode = PuzzlePieceSpriteNode(
                pieceDefinition: pieceDef,
                texture: SKTexture(image: colorImage),
                size: pieceSize,
                targetScenePoint: targetPoint
            )

            if vm.isPiecePlaced(pieceDef.id) {
                pieceNode.lockIntoTarget(animated: false)
            } else {
                // Spawn in lower half of the screen and let gravity drop & settle the pieces naturally
                let columns = max(2, min(4, sortedPieces.count))
                let col = spawnIndex % columns
                let row = spawnIndex / columns
                let horizontalFraction = (CGFloat(col) + 0.5) / CGFloat(columns)
                let spawnX = size.width * (0.16 + horizontalFraction * 0.68)
                let spawnY = size.height * (0.20 + CGFloat(row) * 0.11)
                pieceNode.position = CGPoint(
                    x: min(max(pieceSize.width * 0.6, spawnX), size.width - pieceSize.width * 0.6),
                    y: min(max(pieceSize.height * 0.6 + 30, spawnY), size.height * 0.44)
                )
                // Give each loose piece a subtle initial tilt matching the App Store screenshots
                let initialTilt = (spawnIndex % 2 == 0 ? 1.0 : -1.0) * CGFloat(0.14 + Double(spawnIndex % 3) * 0.08)
                pieceNode.zRotation = initialTilt
                pieceNode.zPosition = CGFloat(100 + spawnIndex)
            }

            boardContainerNode.addChild(pieceNode)
            pieceNodes[pieceDef.id] = pieceNode
        }
    }

    // MARK: - Touch Handling (Bubble Pop, Drag, Snap & Physics Drop)

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 1. Check if the toddler tapped a floating surprise bubble
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let bubble = node as? SurpriseBubbleNode ?? node.parent as? SurpriseBubbleNode {
                bubble.popWithBurst()
                viewModel?.recordSurpriseBubblePop()
                return
            }
        }

        // 2. Pick up the topmost loose puzzle piece under the finger
        let candidatePieces = pieceNodes.values
            .filter { !$0.isSnappedAndLocked && $0.frame.insetBy(dx: -16, dy: -16).contains(location) }
            .sorted { $0.zPosition > $1.zPosition }

        guard let picked = candidatePieces.first else { return }
        activeDraggedPiece = picked
        dragTouchOffset = CGPoint(
            x: picked.position.x - location.x,
            y: picked.position.y - location.y
        )
        picked.beginDrag()
        audioService.playPiecePickup()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let dragged = activeDraggedPiece, !dragged.isSnappedAndLocked else { return }
        let location = touch.location(in: self)
        let desired = CGPoint(
            x: location.x + dragTouchOffset.x,
            y: location.y + dragTouchOffset.y
        )
        let safeBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        dragged.position = GeometryHelpers.clampPoint(desired, inside: safeBounds, inset: 24)

        // Magnetic auto-snap when dragged very close to its target slot
        let magneticRadius: CGFloat = (size.width >= 600) ? 38.0 : 28.0
        if let vm = viewModel,
           vm.shouldSnapPiece(
               currentScenePoint: dragged.position,
               targetScenePoint: dragged.targetScenePoint,
               snapThreshold: magneticRadius
           ) {
            snapAndLockPiece(dragged)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishCurrentDrag()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishCurrentDrag()
    }

    private func finishCurrentDrag() {
        guard let dragged = activeDraggedPiece else { return }
        activeDraggedPiece = nil
        guard !dragged.isSnappedAndLocked else { return }

        let releaseSnapRadius: CGFloat = (size.width >= 600) ? 80.0 : 60.0
        if let vm = viewModel,
           vm.shouldSnapPiece(
               currentScenePoint: dragged.position,
               targetScenePoint: dragged.targetScenePoint,
               snapThreshold: releaseSnapRadius
           ) {
            snapAndLockPiece(dragged)
        } else {
            // Wrong placement: release back to 2D gravity & collisions!
            dragged.releaseBackToPhysics(layerIndex: dragged.pieceDefinition.partIndex)
            viewModel?.handleWrongPlacementDrop(
                for: dragged.pieceDefinition.id,
                at: dragged.position,
                rotation: dragged.zRotation
            )
        }
    }

    // MARK: - Snap & Victory Celebration Effects

    private func snapAndLockPiece(_ pieceNode: PuzzlePieceSpriteNode) {
        let pieceID = pieceNode.pieceDefinition.id
        activeDraggedPiece = nil

        pieceNode.lockIntoTarget(animated: true)
        grayscalePartNodes[pieceID]?.run(SKAction.fadeOut(withDuration: 0.14))
        spawnSnapSparkles(at: pieceNode.targetScenePoint)

        guard let vm = viewModel else { return }
        let didPlace = vm.markPiecePlaced(pieceID)
        if didPlace && vm.isCompleted {
            triggerPuzzleCompletedCelebration()
        }
    }

    private func spawnSnapSparkles(at point: CGPoint) {
        let colors: [UIColor] = [
            ThemeColors.uiColor(250, 214, 42),
            ThemeColors.uiColor(246, 104, 178),
            .white,
            ThemeColors.uiColor(114, 218, 246)
        ]

        for i in 0..<10 {
            let angle = (Double(i) / 10.0) * Double.pi * 2.0
            let spark = SKShapeNode(circleOfRadius: 5.5)
            spark.fillColor = colors[i % colors.count]
            spark.strokeColor = .white
            spark.lineWidth = 1.0
            spark.position = point
            spark.zPosition = 600
            addChild(spark)

            let distance = CGFloat.random(in: 32...64)
            let dx = CGFloat(cos(angle)) * distance
            let dy = CGFloat(sin(angle)) * distance
            let action = SKAction.group([
                SKAction.moveBy(x: dx, y: dy, duration: 0.34),
                SKAction.fadeOut(withDuration: 0.34),
                SKAction.scale(to: 0.2, duration: 0.34)
            ])
            spark.run(SKAction.sequence([action, SKAction.removeFromParent()]))
        }
    }

    private func triggerPuzzleCompletedCelebration() {
        // 1. Joyful bounce of the completed full-color illustration
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.20)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.22)
        scaleDown.timingMode = .easeInEaseOut
        boardContainerNode.run(SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown]))

        // 2. Spawn interactive floating soap bubbles & stars for the toddler to tap and pop
        let bubbleColors: [UIColor] = [
            ThemeColors.uiColor(246, 108, 182),
            ThemeColors.uiColor(98, 206, 246),
            ThemeColors.uiColor(250, 208, 48),
            ThemeColors.uiColor(186, 128, 246),
            ThemeColors.uiColor(124, 234, 142)
        ]

        let spawnOne = SKAction.run { [weak self] in
            guard let self = self else { return }
            let radius = CGFloat.random(in: 26...42)
            let color = bubbleColors.randomElement() ?? .systemPink
            let bubble = SurpriseBubbleNode(radius: radius, tintColor: color)
            let startX = CGFloat.random(in: radius + 24...(self.size.width - radius - 24))
            let startPoint = CGPoint(x: startX, y: -radius)
            let duration = TimeInterval.random(in: 3.4...5.4)
            self.addChild(bubble)
            bubble.startFloating(from: startPoint, toY: self.size.height + radius * 2, duration: duration)
        }

        let spawnSequence = SKAction.sequence([
            spawnOne,
            SKAction.wait(forDuration: 0.26)
        ])
        run(SKAction.repeat(spawnSequence, count: 24), withKey: "victoryBubbles")
    }
}
