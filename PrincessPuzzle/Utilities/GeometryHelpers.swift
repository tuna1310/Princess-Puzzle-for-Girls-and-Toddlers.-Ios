import CoreGraphics
import Foundation

/// Pure mathematical and geometric helper functions for wheel physics and puzzle snapping.
public enum GeometryHelpers {
    /// Calculates the Euclidean distance between two `CGPoint` coordinates.
    public static func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Normalizes an angle in radians into the range `[0, 2π)`.
    public static func normalizeRadians(_ angle: Double) -> Double {
        let twoPi = Double.pi * 2.0
        var result = angle.truncatingRemainder(dividingBy: twoPi)
        if result < 0 {
            result += twoPi
        }
        return result
    }

    /// Computes the shortest signed angular difference in radians from `current` to `target`.
    public static func shortestAngularDelta(from current: Double, to target: Double) -> Double {
        let twoPi = Double.pi * 2.0
        var diff = (target - current).truncatingRemainder(dividingBy: twoPi)
        if diff > Double.pi {
            diff -= twoPi
        } else if diff < -Double.pi {
            diff += twoPi
        }
        return diff
    }

    /// Determines which radial index (`0..<totalCount`) is currently closest to the 12-o'clock top position
    /// given the wheel's cumulative rotation angle in radians.
    public static func activeIndexOnWheel(rotationRadians: Double, totalCount: Int) -> Int {
        guard totalCount > 0 else { return 0 }
        let stepAngle = (Double.pi * 2.0) / Double(totalCount)
        let normalized = normalizeRadians(-rotationRadians)
        let rawIndex = Int(round(normalized / stepAngle)) % totalCount
        return (rawIndex + totalCount) % totalCount
    }

    /// Clamps a point within a bounding rectangle inset by horizontal and vertical margins.
    public static func clampPoint(_ point: CGPoint, inside bounds: CGRect, inset: CGFloat) -> CGPoint {
        let minX = bounds.minX + inset
        let maxX = max(minX, bounds.maxX - inset)
        let minY = bounds.minY + inset
        let maxY = max(minY, bounds.maxY - inset)
        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}
