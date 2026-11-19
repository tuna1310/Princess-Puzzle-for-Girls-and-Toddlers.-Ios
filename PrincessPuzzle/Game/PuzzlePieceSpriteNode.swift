import SpriteKit
import UIKit

/// Collision bitmasks for the 2D SpriteKit physics engine.
public enum PhysicsCategory {
    public static let none: UInt32 = 0
    public static let boundary: UInt32 = 0x1 << 0
    public static let puzzlePiece: UInt32 = 0x1 << 1
    public static let terrainLedge: UInt32 = 0x1 << 2
}

/// SpriteKit node representing a single physics-enabled anatomical puzzle piece.
public final class PuzzlePieceSpriteNode: SKSpriteNode {
    public let pieceDefinition: PuzzlePieceDefinition
    public let targetScenePoint: CGPoint
    public private(set) var isSnappedAndLocked: Bool = false

    public init(
        pieceDefinition: PuzzlePieceDefinition,
        texture: SKTexture,
        size: CGSize,
        targetScenePoint: CGPoint
    ) {
        self.pieceDefinition = pieceDefinition
        self.targetScenePoint = targetScenePoint
        super.init(texture: texture, color: .clear, size: size)
        self.name = "piece_\(pieceDefinition.id)"
        self.isUserInteractionEnabled = false
        configurePhysicsBody(for: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 2D Rigid-Body Physics Configuration

    private func configurePhysicsBody(for size: CGSize) {
        let hitboxSize = CGSize(
            width: max(22, size.width * 0.72),
            height: max(22, size.height * 0.72)
        )
        let body = SKPhysicsBody(rectangleOf: hitboxSize)
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = true
        body.restitution = 0.24
        body.friction = 0.48
        body.linearDamping = 0.35
        body.angularDamping = 0.45
        body.categoryBitMask = PhysicsCategory.puzzlePiece
        body.collisionBitMask = PhysicsCategory.boundary | PhysicsCategory.puzzlePiece | PhysicsCategory.terrainLedge
        body.contactTestBitMask = PhysicsCategory.boundary
        self.physicsBody = body
    }

    /// Called when the toddler touches and picks up the piece.
    public func beginDrag() {
        guard !isSnappedAndLocked else { return }
        removeAction(forKey: "dragTransform")
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        physicsBody?.isDynamic = false
        zPosition = 500

        let upright = SKAction.rotate(toAngle: 0, duration: 0.16, shortestUnitArc: true)
        let scaleUp = SKAction.scale(to: 1.07, duration: 0.14)
        run(SKAction.group([upright, scaleUp]), withKey: "dragTransform")
    }

    /// Called when the piece is released outside its target slot so gravity pulls it back down to the meadow floor.
    public func releaseBackToPhysics(layerIndex: Int) {
        guard !isSnappedAndLocked else { return }
        removeAction(forKey: "dragTransform")
        let scaleReset = SKAction.scale(to: 1.0, duration: 0.12)
        run(scaleReset)
        zPosition = CGFloat(100 + layerIndex)

        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -25...25), dy: -40)
        physicsBody?.angularVelocity = CGFloat.random(in: -1.4...1.4)
    }

    /// Called when the piece is dragged within the snap radius of its matching grayscale silhouette slot.
    public func lockIntoTarget(animated: Bool, completion: (() -> Void)? = nil) {
        isSnappedAndLocked = true
        removeAllActions()
        physicsBody = nil
        zPosition = CGFloat(20 + pieceDefinition.zIndex)

        if animated {
            let move = SKAction.move(to: targetScenePoint, duration: 0.14)
            move.timingMode = .easeOut
            let rotate = SKAction.rotate(toAngle: 0, duration: 0.14, shortestUnitArc: true)
            let popUp = SKAction.scale(to: 1.12, duration: 0.09)
            let popDown = SKAction.scale(to: 1.0, duration: 0.09)
            let sequence = SKAction.sequence([
                SKAction.group([move, rotate, popUp]),
                popDown
            ])
            run(sequence) {
                completion?()
            }
        } else {
            position = targetScenePoint
            zRotation = 0
            setScale(1.0)
            completion?()
        }
    }
}
