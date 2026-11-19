import SwiftUI

/// Screen 1: Rotating Fairy-Tale Planet Carousel Level Selector (`iphone_1.png`, `ipad_3.png`).
public struct PlanetWheelScreenView: View {
    @ObservedObject public var appViewModel: AppViewModel
    @ObservedObject public var wheelViewModel: WheelViewModel

    public init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        self.wheelViewModel = appViewModel.wheelViewModel
    }

    public var body: some View {
        ZStack {
            // 1. Full-screen portrait fairy-tale meadow background
            MeadowBackgroundView(dimmingOpacity: 0.0)

            // 2. Central rotating fairy-tale planet carousel with 16 radial puzzles
            RotatingPlanetWheelView(viewModel: wheelViewModel) { selectedLevel in
                withAnimation(.easeInOut(duration: 0.28)) {
                    appViewModel.selectPuzzle(selectedLevel)
                }
            }

            // 3. Top-Left & Top-Right Blue Curved Rotation Arrows + Minimal Bottom Bar
            VStack {
                HStack(alignment: .top) {
                    CurvedBlueArrowButton(direction: .clockwiseRight) {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                            wheelViewModel.rotateClockwise()
                        }
                    }

                    Spacer()

                    CurvedBlueArrowButton(direction: .counterClockwiseLeft) {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                            wheelViewModel.rotateCounterClockwise()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                bottomStatusBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Subtle Bottom Action Pill (Play Active Puzzle / Sound / Unlock All)

    private var bottomStatusBar: some View {
        HStack(spacing: 12) {
            // Sound toggle button
            Button {
                appViewModel.toggleSound()
            } label: {
                Image(systemName: appViewModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.black.opacity(0.32)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(appViewModel.isSoundEnabled ? "Mute Sound" : "Unmute Sound")

            // Active puzzle quick-play pill
            if let activeLevel = wheelViewModel.activeLevel {
                let unlocked = wheelViewModel.isLevelUnlocked(activeLevel)
                Button {
                    appViewModel.selectPuzzle(activeLevel)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: unlocked ? "play.circle.fill" : "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(unlocked ? .yellow : .white)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(activeLevel.title)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("\(activeLevel.pieceCount) Pieces • \(unlocked ? "Tap to Play" : "Tap to Unlock")")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.88))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: unlocked
                                        ? [Color(red: 0.91, green: 0.24, blue: 0.58).opacity(0.88), Color(red: 0.58, green: 0.14, blue: 0.52).opacity(0.88)]
                                        : [Color.black.opacity(0.45), Color.black.opacity(0.55)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(Capsule().stroke(Color.white.opacity(0.55), lineWidth: 1.5))
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            if !wheelViewModel.isAllPuzzlesUnlocked {
                Button {
                    appViewModel.storeViewModel.presentParentalGate()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Unlock All")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.56, green: 0.14, blue: 0.54).opacity(0.85))
                            .overlay(Capsule().stroke(Color.yellow.opacity(0.75), lineWidth: 1.5))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
