import SwiftUI

/// Reproduces the central rotating fairy-tale planet carousel from `iphone_1.png` and `ipad_3.png`:
/// - Large semi-transparent dark outer wheel disk (`rgba(55, 62, 68, 0.36)`)
/// - Top 12-o'clock vertical white indicator line
/// - Inner pastel pink & creamy-yellow circular planet core with the central 3-tower pink/purple castle
/// - Radial puzzle illustrations standing upright around the planet perimeter
/// - Smooth angular drag gesture + tap-to-play on any puzzle character
public struct RotatingPlanetWheelView: View {
    @ObservedObject public var viewModel: WheelViewModel
    public let onSelectLevel: (PuzzleLevel) -> Void

    @State private var lastDragAngle: Double?

    public init(
        viewModel: WheelViewModel,
        onSelectLevel: @escaping (PuzzleLevel) -> Void
    ) {
        self.viewModel = viewModel
        self.onSelectLevel = onSelectLevel
    }

    public var body: some View {
        GeometryReader { proxy in
            let minDim = min(proxy.size.width * 0.96, proxy.size.height * 0.74)
            let outerDiameter = max(300, minDim)
            let innerPlanetDiameter = outerDiameter * 0.45
            let orbitRadius = outerDiameter * 0.335
            let itemSize = outerDiameter * 0.23
            let center = CGPoint(x: proxy.size.width / 2.0, y: proxy.size.height * 0.44)

            ZStack {
                // 1. Translucent dark outer circular disk (matching iphone_1.png & ipad_3.png)
                Circle()
                    .fill(ThemeColors.wheelOuterOverlay)
                    .frame(width: outerDiameter, height: outerDiameter)
                    .position(center)

                // 2. Top 12-o'clock vertical white selector line
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - outerDiameter * 0.50))
                    path.addLine(to: CGPoint(x: center.x, y: center.y - innerPlanetDiameter * 0.48))
                }
                .stroke(Color.white.opacity(0.85), lineWidth: 2.2)

                // 3. Radial puzzle characters standing around the planet perimeter
                ForEach(viewModel.levels) { level in
                    let baseAngle = Double(level.index) * viewModel.stepAngleRadians
                    let totalAngle = baseAngle + viewModel.wheelRotationRadians
                    // 0 rad is 12 o'clock top; clockwise angle sin/cos
                    let xOffset = CGFloat(sin(totalAngle)) * orbitRadius
                    let yOffset = -CGFloat(cos(totalAngle)) * orbitRadius
                    let isUnlocked = viewModel.isLevelUnlocked(level)
                    let isCompleted = viewModel.isLevelCompleted(level)
                    let isFocusedTop = (level.index == viewModel.activeLevelIndex)

                    Button {
                        onSelectLevel(level)
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            Image(
                                uiImage: PuzzleIllustrationRenderer.shared.renderFullIllustration(
                                    for: level,
                                    size: CGSize(width: 220, height: 240),
                                    grayscale: false
                                )
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: itemSize * (isFocusedTop ? 1.18 : 0.92), height: itemSize * (isFocusedTop ? 1.18 : 0.92))
                            .opacity(isUnlocked ? 1.0 : 0.78)
                            .shadow(
                                color: isFocusedTop ? Color.white.opacity(0.75) : Color.black.opacity(0.18),
                                radius: isFocusedTop ? 6 : 2
                            )

                            if !isUnlocked {
                                Image(systemName: "lock.circle.fill")
                                    .font(.system(size: itemSize * 0.28, weight: .bold))
                                    .foregroundStyle(Color.white, Color(red: 0.85, green: 0.18, blue: 0.48))
                                    .shadow(radius: 2)
                            } else if isCompleted {
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: itemSize * 0.26, weight: .bold))
                                    .foregroundStyle(Color.yellow, Color.orange)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .rotationEffect(.radians(totalAngle))
                    .position(x: center.x + xOffset, y: center.y + yOffset)
                    .zIndex(isFocusedTop ? 20 : Double(16 - level.index))
                    .accessibilityLabel("\(level.title), \(isUnlocked ? "Unlocked" : "Locked")")
                }

                // 4. Inner Fairy-Tale Planet Sphere with central 3-tower pink/purple castle
                innerPlanetCoreView(diameter: innerPlanetDiameter)
                    .rotationEffect(.radians(viewModel.wheelRotationRadians * 0.35))
                    .position(center)
                    .onTapGesture {
                        if let active = viewModel.activeLevel {
                            onSelectLevel(active)
                        }
                    }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 6)
                    .onChanged { value in
                        let dx = Double(value.location.x - center.x)
                        let dy = Double(value.location.y - center.y)
                        let currentAngle = atan2(dx, -dy)
                        if let previous = lastDragAngle {
                            let delta = GeometryHelpers.shortestAngularDelta(from: previous, to: currentAngle)
                            viewModel.applyDragRotation(deltaRadians: delta)
                        }
                        lastDragAngle = currentAngle
                    }
                    .onEnded { _ in
                        lastDragAngle = nil
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            viewModel.snapToNearestLevel()
                        }
                    }
            )
        }
    }

    // MARK: - Inner Pastel Planet Core (Matches central globe in iphone_1.png & ipad_3.png)

    @ViewBuilder
    private func innerPlanetCoreView(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [ThemeColors.planetUpperPink, ThemeColors.planetLowerCream],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle()
                        .stroke(ThemeColors.planetRimPink.opacity(0.85), lineWidth: 5)
                )

            if let castleLevel = viewModel.levels.first {
                Image(
                    uiImage: PuzzleIllustrationRenderer.shared.renderFullIllustration(
                        for: castleLevel,
                        size: CGSize(width: 220, height: 220),
                        grayscale: false
                    )
                )
                .resizable()
                .scaledToFit()
                .frame(width: diameter * 0.74, height: diameter * 0.74)
            }
        }
    }
}
