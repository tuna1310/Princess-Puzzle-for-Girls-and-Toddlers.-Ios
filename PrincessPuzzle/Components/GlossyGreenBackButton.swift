import SwiftUI

/// Reproduces the chunky glossy green left-pointing back arrow button (`⬅`) at the top-left of all gameplay screenshots (`iphone_2..5.png`, `ipad_1,2,4,5.png`).
public struct GlossyGreenBackButton: View {
    public let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Canvas { context, size in
                let w = size.width
                let h = size.height

                var arrow = Path()
                // Left tip
                arrow.move(to: CGPoint(x: w * 0.08, y: h * 0.50))
                // Top wing tip
                arrow.addLine(to: CGPoint(x: w * 0.52, y: h * 0.08))
                arrow.addQuadCurve(
                    to: CGPoint(x: w * 0.58, y: h * 0.16),
                    control: CGPoint(x: w * 0.58, y: h * 0.08)
                )
                // Inner top corner
                arrow.addLine(to: CGPoint(x: w * 0.58, y: h * 0.33))
                // Right shaft top
                arrow.addLine(to: CGPoint(x: w * 0.88, y: h * 0.33))
                arrow.addQuadCurve(
                    to: CGPoint(x: w * 0.94, y: h * 0.42),
                    control: CGPoint(x: w * 0.94, y: h * 0.33)
                )
                // Right shaft bottom
                arrow.addLine(to: CGPoint(x: w * 0.94, y: h * 0.58))
                arrow.addQuadCurve(
                    to: CGPoint(x: w * 0.88, y: h * 0.67),
                    control: CGPoint(x: w * 0.94, y: h * 0.67)
                )
                // Inner bottom corner
                arrow.addLine(to: CGPoint(x: w * 0.58, y: h * 0.67))
                // Bottom wing tip
                arrow.addLine(to: CGPoint(x: w * 0.58, y: h * 0.84))
                arrow.addQuadCurve(
                    to: CGPoint(x: w * 0.52, y: h * 0.92),
                    control: CGPoint(x: w * 0.58, y: h * 0.92)
                )
                arrow.closeSubpath()

                context.fill(
                    arrow,
                    with: .linearGradient(
                        Gradient(colors: [ThemeColors.greenArrowTop, ThemeColors.greenArrowBottom]),
                        startPoint: CGPoint(x: w * 0.5, y: h * 0.08),
                        endPoint: CGPoint(x: w * 0.5, y: h * 0.92)
                    )
                )
                context.stroke(
                    arrow,
                    with: .color(ThemeColors.greenArrowBorder),
                    style: StrokeStyle(lineWidth: 4.2, lineCap: .round, lineJoin: .round)
                )
            }
            .frame(width: 66, height: 56)
            .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back to Puzzle Wheel")
    }
}
