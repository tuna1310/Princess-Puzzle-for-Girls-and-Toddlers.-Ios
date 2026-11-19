import SwiftUI

/// Non-blocking celebration banner displayed at the bottom of the screen when a puzzle is completed
/// while floating soap bubbles and stars drift across the SpriteKit meadow for the toddler to tap and pop.
public struct SurpriseCelebrationOverlayView: View {
    @ObservedObject public var viewModel: GameplayViewModel
    public let onReplay: () -> Void
    public let onNextPuzzle: () -> Void

    public init(
        viewModel: GameplayViewModel,
        onReplay: @escaping () -> Void,
        onNextPuzzle: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onReplay = onReplay
        self.onNextPuzzle = onNextPuzzle
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Horray! Tap the Floating Bubbles!")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                if viewModel.poppedBubblesCount > 0 {
                    Text("• \(viewModel.poppedBubblesCount) Popped!")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }

            HStack(spacing: 16) {
                Button(action: onReplay) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Play Again")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.56, blue: 0.88))
                            .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
                    )
                }
                .buttonStyle(.plain)

                Button(action: onNextPuzzle) {
                    HStack(spacing: 6) {
                        Text("Next Puzzle")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.93, green: 0.24, blue: 0.59), Color(red: 0.65, green: 0.14, blue: 0.54)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(Capsule().stroke(Color.yellow, lineWidth: 2.0))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.46))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                )
        )
        .padding(.bottom, 16)
    }
}
