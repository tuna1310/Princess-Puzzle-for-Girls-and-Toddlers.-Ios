import SpriteKit
import UIKit

/// Floating soap bubble / star / crown node for the interactive puzzle completion surprise mini-game.
/// Matches Tommy Hass's verified reward mechanic:
/// *"When the puzzle is completed, the player is rewarded with bubbles that appear on the screen, for the player to tap and pop."*
public final class SurpriseBubbleNode: SKNode {
    public private(set) var isPopped: Bool = false
    private let bubbleRadius: CGFloat
    private let tintColor: UIColor

    public init(radius: CGFloat, tintColor: UIColor) {
        self.bubbleRadius = radius
        self.tintColor = tintColor
        super.init()
        self.name = "surprise_bubble"
        buildVisualHierarchy()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisualHierarchy() {
        // Outer translucent soap bubble sphere
        let outer = SKShapeNode(circleOfRadius: bubbleRadius)
        outer.fillColor = tintColor.withAlphaComponent(0.38)
        outer.strokeColor = UIColor.white.withAlphaComponent(0.88)
        outer.lineWidth = 2.5
        addChild(outer)

        // Glossy specular highlight crescent inside top-left of bubble
        let highlight = SKShapeNode(circleOfRadius: bubbleRadius * 0.24)
        highlight.fillColor = UIColor.white.withAlphaComponent(0.82)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -bubbleRadius * 0.34, y: bubbleRadius * 0.34)
        addChild(highlight)

        // Tiny golden star or heart inside the bubble
        let star = SKShapeNode(circleOfRadius: bubbleRadius * 0.16)
        star.fillColor = ThemeColors.uiColor(250, 214, 42).withAlphaComponent(0.85)
        star.strokeColor = .clear
        addChild(star)
    }

    /// Starts floating upward from `startPoint` to `topY` with a gentle horizontal sine oscillation.
    public func startFloating(from startPoint: CGPoint, toY topY: CGFloat, duration: TimeInterval) {
        position = startPoint
        zPosition = 700
        setScale(0.2)

        let appear = SKAction.scale(to: 1.0, duration: 0.22)
        let moveUp = SKAction.moveTo(y: topY, duration: duration)
        let swayRight = SKAction.moveBy(x: 24, y: 0, duration: 0.9)
        swayRight.timingMode = .easeInEaseOut
        let swayLeft = swayRight.reversed()
        let swayLoop = SKAction.repeatForever(SKAction.sequence([swayRight, swayLeft]))

        run(appear)
        run(swayLoop, withKey: "sway")
        run(SKAction.sequence([moveUp, SKAction.removeFromParent()]))
    }

    /// Pops the bubble with an expanding ring and particle burst when tapped by the toddler.
    public func popWithBurst() {
        guard !isPopped else { return }
        isPopped = true
        removeAllActions()

        if let parentScene = scene {
            for i in 0..<8 {
                let angle = (Double(i) / 8.0) * Double.pi * 2.0
                let drop = SKShapeNode(circleOfRadius: 5)
                drop.fillColor = (i % 2 == 0) ? .white : tintColor
                drop.strokeColor = .clear
                drop.position = position
                drop.zPosition = 750
                parentScene.addChild(drop)

                let dx = CGFloat(cos(angle)) * bubbleRadius * 1.4
                let dy = CGFloat(sin(angle)) * bubbleRadius * 1.4
                let burst = SKAction.group([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.26),
                    SKAction.fadeOut(withDuration: 0.26),
                    SKAction.scale(to: 0.2, duration: 0.26)
                ])
                drop.run(SKAction.sequence([burst, SKAction.removeFromParent()]))
            }
        }

        let popExpand = SKAction.group([
            SKAction.scale(to: 1.45, duration: 0.12),
            SKAction.fadeOut(withDuration: 0.12)
        ])
        run(SKAction.sequence([popExpand, SKAction.removeFromParent()]))
    }
}
