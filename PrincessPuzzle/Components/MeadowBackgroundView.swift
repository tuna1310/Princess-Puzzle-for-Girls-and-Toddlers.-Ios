import SwiftUI

/// Renders the exact portrait fairy-tale meadow landscape from all 10 official App Store screenshots:
/// sky & clouds, layered rolling green hills, pine & leafy trees, winding blue river with wave ripples,
/// curved wooden plank bridge, winding sandy footpath, scattered tiny white wildflowers, and two large bottom-right daisies.
public struct MeadowBackgroundView: View {
    public let dimmingOpacity: Double

    public init(dimmingOpacity: Double = 0.0) {
        self.dimmingOpacity = dimmingOpacity
    }

    public var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                drawSkyAndClouds(context: &context, size: size)
                drawRollingHillsAndTrees(context: &context, size: size)
                drawRiverAndWaves(context: &context, size: size)
                drawSandyFootpath(context: &context, size: size)
                drawWoodenPlankBridge(context: &context, size: size)
                drawMeadowWildflowers(context: &context, size: size)
                drawBottomRightDaisies(context: &context, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(
                Color.black.opacity(dimmingOpacity)
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - 1. Sky & Fluffy Clouds

    private func drawSkyAndClouds(context: inout GraphicsContext, size: CGSize) {
        let skyRect = CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.35)
        context.fill(
            Path(skyRect),
            with: .linearGradient(
                Gradient(colors: [ThemeColors.skyTopBlue, ThemeColors.skyHorizonBlue]),
                startPoint: CGPoint(x: size.width * 0.5, y: 0),
                endPoint: CGPoint(x: size.width * 0.5, y: size.height * 0.30)
            )
        )

        drawCloud(context: &context, center: CGPoint(x: size.width * 0.21, y: size.height * 0.085), scale: size.width * 0.0022, isLight: true)
        drawCloud(context: &context, center: CGPoint(x: size.width * 0.43, y: size.height * 0.048), scale: size.width * 0.0031, isLight: true)
        drawCloud(context: &context, center: CGPoint(x: size.width * 0.63, y: size.height * 0.095), scale: size.width * 0.0026, isLight: false)
        drawCloud(context: &context, center: CGPoint(x: size.width * 0.96, y: size.height * 0.060), scale: size.width * 0.0020, isLight: true)
    }

    private func drawCloud(context: inout GraphicsContext, center: CGPoint, scale: CGFloat, isLight: Bool) {
        let fillColor = isLight ? Color.white.opacity(0.92) : Color(red: 0.84, green: 0.88, blue: 0.91).opacity(0.88)
        let offsets: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-22, 2, 26, 18),
            (-8, -6, 30, 22),
            (10, -4, 28, 20),
            (22, 3, 24, 16),
            (0, 4, 36, 18)
        ]
        for (dx, dy, w, h) in offsets {
            let rect = CGRect(
                x: center.x + dx * scale - (w * scale) / 2,
                y: center.y + dy * scale - (h * scale) / 2,
                width: w * scale,
                height: h * scale
            )
            context.fill(Path(ellipseIn: rect), with: .color(fillColor))
        }
    }

    // MARK: - 2. Layered Rolling Green Hills & Trees

    private func drawRollingHillsAndTrees(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Distant right hill
        var hill1 = Path()
        hill1.move(to: CGPoint(x: w * 0.48, y: h * 0.30))
        hill1.addQuadCurve(to: CGPoint(x: w, y: h * 0.18), control: CGPoint(x: w * 0.80, y: h * 0.17))
        hill1.addLine(to: CGPoint(x: w, y: h * 0.55))
        hill1.addLine(to: CGPoint(x: w * 0.48, y: h * 0.55))
        hill1.closeSubpath()
        context.fill(hill1, with: .color(ThemeColors.meadowHillLight))

        // Distant left sunlit hill
        var hill2 = Path()
        hill2.move(to: CGPoint(x: 0, y: h * 0.15))
        hill2.addQuadCurve(to: CGPoint(x: w * 0.65, y: h * 0.33), control: CGPoint(x: w * 0.30, y: h * 0.16))
        hill2.addLine(to: CGPoint(x: w * 0.65, y: h * 0.60))
        hill2.addLine(to: CGPoint(x: 0, y: h * 0.60))
        hill2.closeSubpath()
        context.fill(hill2, with: .color(ThemeColors.meadowHillLight))

        // Upper-left tree line
        for i in 0..<6 {
            let tx = w * (0.03 + CGFloat(i) * 0.055)
            let ty = h * (0.14 + CGFloat(i % 2) * 0.012)
            let r = w * (0.042 - CGFloat(i % 3) * 0.005)
            context.fill(
                Path(ellipseIn: CGRect(x: tx - r, y: ty - r * 0.7, width: r * 2, height: r * 1.4)),
                with: .color(ThemeColors.meadowHillMid)
            )
        }

        // Midground rolling hill
        var hill3 = Path()
        hill3.move(to: CGPoint(x: 0, y: h * 0.25))
        hill3.addCurve(
            to: CGPoint(x: w, y: h * 0.34),
            control1: CGPoint(x: w * 0.38, y: h * 0.23),
            control2: CGPoint(x: w * 0.70, y: h * 0.38)
        )
        hill3.addLine(to: CGPoint(x: w, y: h * 0.70))
        hill3.addLine(to: CGPoint(x: 0, y: h * 0.70))
        hill3.closeSubpath()
        context.fill(hill3, with: .color(ThemeColors.meadowHillMid))

        // Pine trees on right hillside (matching screenshots)
        let pinePositions: [(CGFloat, CGFloat, CGFloat)] = [
            (0.66, 0.35, 0.055),
            (0.71, 0.34, 0.068),
            (0.76, 0.345, 0.065),
            (0.81, 0.36, 0.058),
            (0.21, 0.41, 0.048),
            (0.25, 0.40, 0.056)
        ]
        for (px, py, pScale) in pinePositions {
            drawPineTree(context: &context, baseCenter: CGPoint(x: w * px, y: h * py), height: h * pScale)
        }

        // Foreground deep green meadow base
        var hill4 = Path()
        hill4.move(to: CGPoint(x: 0, y: h * 0.38))
        hill4.addCurve(
            to: CGPoint(x: w, y: h * 0.45),
            control1: CGPoint(x: w * 0.32, y: h * 0.34),
            control2: CGPoint(x: w * 0.68, y: h * 0.48)
        )
        hill4.addLine(to: CGPoint(x: w, y: h))
        hill4.addLine(to: CGPoint(x: 0, y: h))
        hill4.closeSubpath()
        context.fill(hill4, with: .color(ThemeColors.meadowHillDeep))

        // Lower meadow grass overlay below the river
        var lowerMeadow = Path()
        lowerMeadow.move(to: CGPoint(x: 0, y: h * 0.65))
        lowerMeadow.addQuadCurve(to: CGPoint(x: w, y: h * 0.58), control: CGPoint(x: w * 0.52, y: h * 0.61))
        lowerMeadow.addLine(to: CGPoint(x: w, y: h))
        lowerMeadow.addLine(to: CGPoint(x: 0, y: h))
        lowerMeadow.closeSubpath()
        context.fill(lowerMeadow, with: .color(ThemeColors.meadowForegroundGreen))

        // Bush cluster in middle-ground
        let bushCenters: [(CGFloat, CGFloat, CGFloat)] = [
            (0.37, 0.44, 0.038),
            (0.43, 0.48, 0.042),
            (0.51, 0.51, 0.045),
            (0.60, 0.52, 0.050),
            (0.03, 0.62, 0.048)
        ]
        for (bx, by, br) in bushCenters {
            let r = w * br
            let rect = CGRect(x: w * bx - r, y: h * by - r, width: r * 2, height: r * 2)
            context.fill(Path(ellipseIn: rect), with: .color(ThemeColors.forestPineGreen))
        }
    }

    private func drawPineTree(context: inout GraphicsContext, baseCenter: CGPoint, height: CGFloat) {
        let width = height * 0.52
        for layer in 0..<3 {
            let layerBottomY = baseCenter.y - CGFloat(layer) * (height * 0.25)
            let layerTopY = layerBottomY - height * 0.45
            let layerHalfW = (width * 0.5) * (1.0 - CGFloat(layer) * 0.18)
            var tri = Path()
            tri.move(to: CGPoint(x: baseCenter.x, y: layerTopY))
            tri.addLine(to: CGPoint(x: baseCenter.x - layerHalfW, y: layerBottomY))
            tri.addLine(to: CGPoint(x: baseCenter.x + layerHalfW, y: layerBottomY))
            tri.closeSubpath()
            context.fill(tri, with: .color(ThemeColors.forestPineGreen))
        }
    }

    // MARK: - 3. Winding Blue River & Wave Ripples

    private func drawRiverAndWaves(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        var river = Path()
        river.move(to: CGPoint(x: 0, y: h * 0.63))
        river.addCurve(
            to: CGPoint(x: w, y: h * 0.74),
            control1: CGPoint(x: w * 0.35, y: h * 0.57),
            control2: CGPoint(x: w * 0.68, y: h * 0.67)
        )
        river.addLine(to: CGPoint(x: w, y: h * 0.82))
        river.addCurve(
            to: CGPoint(x: 0, y: h * 0.66),
            control1: CGPoint(x: w * 0.66, y: h * 0.74),
            control2: CGPoint(x: w * 0.32, y: h * 0.64)
        )
        river.closeSubpath()
        context.fill(river, with: .color(ThemeColors.riverBlue))

        // White-blue wave ripples
        let wavePoints: [(CGFloat, CGFloat)] = [
            (0.20, 0.635), (0.28, 0.642), (0.37, 0.632),
            (0.45, 0.655), (0.53, 0.675), (0.78, 0.740),
            (0.86, 0.762), (0.92, 0.770)
        ]
        for (wx, wy) in wavePoints {
            var wave = Path()
            let cx = w * wx
            let cy = h * wy
            let span = w * 0.035
            wave.move(to: CGPoint(x: cx - span, y: cy))
            wave.addQuadCurve(to: CGPoint(x: cx, y: cy - 3), control: CGPoint(x: cx - span * 0.5, y: cy + 3))
            wave.addQuadCurve(to: CGPoint(x: cx + span, y: cy), control: CGPoint(x: cx + span * 0.5, y: cy + 3))
            context.stroke(wave, with: .color(ThemeColors.riverWaveHighlight), lineWidth: 2.0)
        }
    }

    // MARK: - 4. Winding Golden-Sand Footpath

    private func drawSandyFootpath(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        var path = Path()
        // Lower path from bottom center to bridge
        path.move(to: CGPoint(x: w * 0.36, y: h))
        path.addCurve(
            to: CGPoint(x: w * 0.57, y: h * 0.73),
            control1: CGPoint(x: w * 0.18, y: h * 0.87),
            control2: CGPoint(x: w * 0.42, y: h * 0.79)
        )
        path.addLine(to: CGPoint(x: w * 0.63, y: h * 0.74))
        path.addCurve(
            to: CGPoint(x: w * 0.54, y: h),
            control1: CGPoint(x: w * 0.46, y: h * 0.81),
            control2: CGPoint(x: w * 0.30, y: h * 0.90)
        )
        path.closeSubpath()
        context.fill(path, with: .color(ThemeColors.sandyPathGold.opacity(0.82)))

        // Upper path from bridge into right hillside
        var upperPath = Path()
        upperPath.move(to: CGPoint(x: w * 0.77, y: h * 0.70))
        upperPath.addCurve(
            to: CGPoint(x: w, y: h * 0.585),
            control1: CGPoint(x: w * 0.92, y: h * 0.68),
            control2: CGPoint(x: w * 0.88, y: h * 0.60)
        )
        upperPath.addLine(to: CGPoint(x: w, y: h * 0.60))
        upperPath.addCurve(
            to: CGPoint(x: w * 0.81, y: h * 0.715),
            control1: CGPoint(x: w * 0.91, y: h * 0.615),
            control2: CGPoint(x: w * 0.95, y: h * 0.695)
        )
        upperPath.closeSubpath()
        context.fill(upperPath, with: .color(ThemeColors.sandyPathGold.opacity(0.82)))
    }

    // MARK: - 5. Curved Wooden Plank Bridge

    private func drawWoodenPlankBridge(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        var bridgeBase = Path()
        bridgeBase.move(to: CGPoint(x: w * 0.56, y: h * 0.725))
        bridgeBase.addQuadCurve(
            to: CGPoint(x: w * 0.83, y: h * 0.71),
            control: CGPoint(x: w * 0.69, y: h * 0.65)
        )
        bridgeBase.addLine(to: CGPoint(x: w * 0.79, y: h * 0.725))
        bridgeBase.addQuadCurve(
            to: CGPoint(x: w * 0.62, y: h * 0.748),
            control: CGPoint(x: w * 0.70, y: h * 0.695)
        )
        bridgeBase.closeSubpath()
        context.fill(bridgeBase, with: .color(ThemeColors.woodenBridgeBrown))
        context.stroke(bridgeBase, with: .color(ThemeColors.woodenBridgeDark), lineWidth: 2.0)

        // Plank divider lines
        for i in 1...5 {
            let t = CGFloat(i) / 6.0
            let bx = w * (0.58 + t * 0.22)
            let by = h * (0.72 - sin(t * .pi) * 0.032)
            var plank = Path()
            plank.move(to: CGPoint(x: bx - w * 0.02, y: by - h * 0.012))
            plank.addLine(to: CGPoint(x: bx + w * 0.02, y: by + h * 0.015))
            context.stroke(plank, with: .color(ThemeColors.woodenBridgeDark.opacity(0.75)), lineWidth: 1.8)
        }
    }

    // MARK: - 6. Scattered Meadow Wildflowers & Bottom-Right Daisies

    private func drawMeadowWildflowers(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        // Deterministic positions matching the clusters along the river and path in the screenshots
        let flowerClusters: [(CGFloat, CGFloat)] = [
            (0.08, 0.70), (0.11, 0.71), (0.14, 0.69), (0.17, 0.72), (0.19, 0.70),
            (0.22, 0.73), (0.25, 0.71), (0.28, 0.74), (0.12, 0.76), (0.15, 0.78),
            (0.06, 0.78), (0.09, 0.80), (0.13, 0.82), (0.18, 0.83), (0.21, 0.81),
            (0.34, 0.72), (0.37, 0.73), (0.39, 0.71), (0.45, 0.79), (0.48, 0.80),
            (0.35, 0.85), (0.38, 0.86), (0.41, 0.88), (0.44, 0.91), (0.47, 0.92),
            (0.50, 0.94), (0.53, 0.93), (0.72, 0.60), (0.75, 0.59), (0.78, 0.61),
            (0.82, 0.63), (0.85, 0.65), (0.93, 0.64), (0.96, 0.66)
        ]

        let dotRadius = max(2.2, w * 0.0065)
        for (fx, fy) in flowerClusters {
            let center = CGPoint(x: w * fx, y: h * fy)
            let rect = CGRect(x: center.x - dotRadius, y: center.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(ThemeColors.daisyPetalWhite.opacity(0.92)))
        }
    }

    private func drawBottomRightDaisies(context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        drawLargeDaisy(
            context: &context,
            center: CGPoint(x: w * 0.92, y: h * 0.915),
            radius: w * 0.058
        )
        drawLargeDaisy(
            context: &context,
            center: CGPoint(x: w * 0.93, y: h * 0.968),
            radius: w * 0.050
        )
    }

    private func drawLargeDaisy(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let petalCount = 6
        for i in 0..<petalCount {
            let angle = (Double(i) / Double(petalCount)) * Double.pi * 2.0
            let px = center.x + CGFloat(cos(angle)) * (radius * 0.55)
            let py = center.y + CGFloat(sin(angle)) * (radius * 0.42)
            let petalRect = CGRect(
                x: px - radius * 0.46,
                y: py - radius * 0.30,
                width: radius * 0.92,
                height: radius * 0.60
            )
            context.fill(Path(ellipseIn: petalRect), with: .color(ThemeColors.daisyPetalWhite))
        }
        let centerRect = CGRect(
            x: center.x - radius * 0.34,
            y: center.y - radius * 0.24,
            width: radius * 0.68,
            height: radius * 0.48
        )
        context.fill(Path(ellipseIn: centerRect), with: .color(ThemeColors.daisyCenterYellow))
    }
}
