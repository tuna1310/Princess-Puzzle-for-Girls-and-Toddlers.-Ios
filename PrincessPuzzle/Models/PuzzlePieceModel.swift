import CoreGraphics
import Foundation

/// Defines a single anatomical/component puzzle piece within a `PuzzleLevel`.
/// Coordinates are normalized (`0.0 ... 1.0`) within the puzzle's target canvas (`320 x 360 pt` reference space)
/// so they scale accurately across every iPhone and iPad screen size.
public struct PuzzlePieceDefinition: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let partIndex: Int
    public let name: String
    /// Normalized center X (`0.0 ... 1.0`) inside the target silhouette frame.
    public let normalizedCenterX: CGFloat
    /// Normalized center Y (`0.0 ... 1.0`, top-to-bottom in UIKit/CoreGraphics space) inside the target silhouette frame.
    public let normalizedCenterY: CGFloat
    /// Normalized width (`0.0 ... 1.0`) relative to the target silhouette frame width.
    public let normalizedWidth: CGFloat
    /// Normalized height (`0.0 ... 1.0`) relative to the target silhouette frame height.
    public let normalizedHeight: CGFloat
    /// Layering order when assembled on the target silhouette.
    public let zIndex: Int

    public init(
        id: String,
        partIndex: Int,
        name: String,
        normalizedCenterX: CGFloat,
        normalizedCenterY: CGFloat,
        normalizedWidth: CGFloat,
        normalizedHeight: CGFloat,
        zIndex: Int
    ) {
        self.id = id
        self.partIndex = partIndex
        self.name = name
        self.normalizedCenterX = normalizedCenterX
        self.normalizedCenterY = normalizedCenterY
        self.normalizedWidth = normalizedWidth
        self.normalizedHeight = normalizedHeight
        self.zIndex = zIndex
    }

    public var normalizedRect: CGRect {
        CGRect(
            x: normalizedCenterX - normalizedWidth / 2.0,
            y: normalizedCenterY - normalizedHeight / 2.0,
            width: normalizedWidth,
            height: normalizedHeight
        )
    }
}

/// Live runtime state of an active puzzle piece during gameplay.
public struct PuzzlePieceRuntimeState: Identifiable, Equatable, Sendable {
    public let definition: PuzzlePieceDefinition
    public var isPlaced: Bool
    public var currentPosition: CGPoint
    public var targetPosition: CGPoint
    public var currentRotationRadians: CGFloat

    public var id: String {
        definition.id
    }

    public init(
        definition: PuzzlePieceDefinition,
        isPlaced: Bool = false,
        currentPosition: CGPoint = .zero,
        targetPosition: CGPoint = .zero,
        currentRotationRadians: CGFloat = 0.0
    ) {
        self.definition = definition
        self.isPlaced = isPlaced
        self.currentPosition = currentPosition
        self.targetPosition = targetPosition
        self.currentRotationRadians = currentRotationRadians
    }
}
