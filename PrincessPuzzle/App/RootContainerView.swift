import SwiftUI

/// Root container view coordinating navigation between the Planet Carousel Wheel, Physics Puzzle Gameplay, and Kid-Safe Parental Gate.
public struct RootContainerView: View {
    @StateObject private var appViewModel = AppViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            switch appViewModel.currentRoute {
            case .planetWheel:
                PlanetWheelScreenView(appViewModel: appViewModel)
                    .transition(.opacity)

            case .puzzleGameplay:
                if let gameplayVM = appViewModel.activeGameplayViewModel {
                    PuzzleGameplayScreenView(
                        appViewModel: appViewModel,
                        gameplayViewModel: gameplayVM
                    )
                    .id(gameplayVM.level.id)
                    .transition(.opacity)
                }
            }

            // Kid-Safe Parental Gate & StoreKit 2 Unlock All Modal
            ParentalGateModalView(storeViewModel: appViewModel.storeViewModel)
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }
}
