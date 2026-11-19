import SpriteKit
import SwiftUI
import UIKit

/// UIKit `SKView` bridge that guarantees transparent background rendering over `MeadowBackgroundView`.
public struct TransparentSpriteKitContainerView: UIViewRepresentable {
    public let scene: PuzzlePhysicsScene

    public init(scene: PuzzlePhysicsScene) {
        self.scene = scene
    }

    public func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: .zero)
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        skView.isMultipleTouchEnabled = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        skView.presentScene(scene)
        return skView
    }

    public func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene !== scene {
            scene.scaleMode = .resizeFill
            scene.backgroundColor = .clear
            uiView.presentScene(scene)
        }
    }
}

/// Screen 2: Physics-Enabled Puzzle Gameplay Screen (`iphone_2..5.png`, `ipad_1,2,4,5.png`).
public struct PuzzleGameplayScreenView: View {
    @ObservedObject public var appViewModel: AppViewModel
    @ObservedObject public var gameplayViewModel: GameplayViewModel
    @State private var physicsScene: PuzzlePhysicsScene

    public init(appViewModel: AppViewModel, gameplayViewModel: GameplayViewModel) {
        self.appViewModel = appViewModel
        self.gameplayViewModel = gameplayViewModel
        _physicsScene = State(
            initialValue: PuzzlePhysicsScene(
                size: CGSize(width: 392, height: 696),
                viewModel: gameplayViewModel
            )
        )
    }

    public var body: some View {
        ZStack {
            // 1. Dimmed portrait meadow background (matching iphone_2..5.png & ipad_1,2,4,5.png)
            MeadowBackgroundView(dimmingOpacity: 0.18)

            // 2. Transparent 2D SpriteKit physics canvas (grayscale silhouette + falling rigid-body pieces)
            TransparentSpriteKitContainerView(scene: physicsScene)
                .ignoresSafeArea()

            // 3. Top-Left Glossy Green Back Arrow + Victory Surprise Celebration Controls
            VStack {
                HStack {
                    GlossyGreenBackButton {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            appViewModel.returnToWheel(advanceToNextIfCompleted: true)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)

                Spacer()

                if gameplayViewModel.isSurpriseActive {
                    SurpriseCelebrationOverlayView(
                        viewModel: gameplayViewModel,
                        onReplay: {
                            gameplayViewModel.resetLevel()
                            physicsScene.rebuildSceneIfNeeded(force: true)
                        },
                        onNextPuzzle: {
                            withAnimation(.easeInOut(duration: 0.28)) {
                                appViewModel.advanceToNextPuzzle()
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.80), value: gameplayViewModel.isSurpriseActive)
        }
        .onChange(of: gameplayViewModel.level.id) { _ in
            let nextScene = PuzzlePhysicsScene(
                size: physicsScene.size,
                viewModel: gameplayViewModel
            )
            physicsScene = nextScene
        }
    }
}
