import SwiftUI

/// Direction for the top-left and top-right glossy blue curved rotation arrows on the Planet Wheel screen (`iphone_1.png`, `ipad_3.png`).
public enum CurvedArrowDirection {
    /// Top-Left button (`↷`): curves up and points right/down-right.
    case clockwiseRight
    /// Top-Right button (`↶`): curves up and points left/down-left.
    case counterClockwiseLeft
}

/// Reproduces the top-left and top-right glossy blue curved arrow buttons with elliptical ground shadows from `iphone_1.png` and `ipad_3.png`.
public struct CurvedBlueArrowButton: View {
    public let direction: CurvedArrowDirection
    public let action: () -> Void

    public init(direction: CurvedArrowDirection, action: @escaping () -> Void) {
        self.direction = direction
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Canvas { context, size in
                    drawCurvedArrow(context: &context, size: size)
                }
                .frame(width: 66, height: 48)
                .scaleEffect(x: direction == .clockwiseRight ? 1.0 : -1.0, y: 1.0)

                // Subtle elliptical floating shadow below the arrow (matching iphone_1.png)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.38), Color.clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 7)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(direction == .clockwiseRight ? "Rotate Wheel Clockwise" : "Rotate Wheel Counter-Clockwise")
    }

    private func drawCurvedArrow(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        var arrow = Path()
        // Tail at bottom-left curving over top arch into a large arrowhead on the right
        arrow.move(to: CGPoint(x: w * 0.25, y: h * 0.94))
        arrow.addCurve(
            to: CGPoint(x: w * 0.66, y: h * 0.26),
            control1: CGPoint(x: -w * 0.02, y: h * 0.72),
            control2: CGPoint(x: w * 0.14, y: -h * 0.05)
        )
        // Upper wing of arrowhead
        arrow.addLine(to: CGPoint(x: w * 0.92, y: h * 0.06))
        // Right vertical edge of arrowhead
        arrow.addLine(to: CGPoint(x: w * 0.92, y: h * 0.80))
        // Bottom edge of arrowhead
        arrow.addLine(to: CGPoint(x: w * 0.34, y: h * 0.80))
        // Inner lower wing of arrowhead
        arrow.addLine(to: CGPoint(x: w * 0.54, y: h * 0.56))
        // Inner arch curve back to tail
        arrow.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.94),
            control1: CGPoint(x: w * 0.28, y: h * 0.28),
            control2: CGPoint(x: w * 0.12, y: h * 0.64)
        )
        arrow.closeSubpath()

        context.fill(
            arrow,
            with: .linearGradient(
                Gradient(colors: [ThemeColors.blueArrowTop, ThemeColors.blueArrowBottom]),
                startPoint: CGPoint(x: w * 0.5, y: 0),
                endPoint: CGPoint(x: w * 0.5, y: h)
            )
        )
        context.stroke(arrow, with: .color(Color.white.opacity(0.65)), lineWidth: 2.2)
        context.stroke(arrow, with: .color(ThemeColors.blueArrowBorder), lineWidth: 1.2)
    }
}
