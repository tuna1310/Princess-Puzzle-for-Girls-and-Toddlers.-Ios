import Combine
import Foundation

/// ViewModel coordinating the Kid-Safe Parental Gate and StoreKit 2 `"Unlock all puzzles ($2.99)"` flow.
public final class StoreViewModel: ObservableObject {
    @Published public var isParentalGatePresented: Bool = false
    @Published public var isStoreSheetPresented: Bool = false
    @Published public private(set) var currentChallenge: ParentalChallenge
    @Published public private(set) var parentalGateErrorMessage: String?
    @Published public private(set) var isProcessingPurchase: Bool = false
    @Published public private(set) var storeStatusMessage: String?
    @Published public private(set) var isAllUnlocked: Bool

    private let storeService: StoreServiceProtocol
    private let progressRepository: ProgressRepositoryProtocol
    private var onUnlockCompleted: (() -> Void)?

    public var productTitle: String {
        storeService.displayTitle
    }

    public var productPrice: String {
        storeService.displayPrice
    }

    public init(
        storeService: StoreServiceProtocol = StoreService.shared,
        progressRepository: ProgressRepositoryProtocol = ProgressRepository.shared,
        onUnlockCompleted: (() -> Void)? = nil
    ) {
        self.storeService = storeService
        self.progressRepository = progressRepository
        self.onUnlockCompleted = onUnlockCompleted
        self.currentChallenge = ParentalChallenge.generateRandom()
        self.isAllUnlocked = progressRepository.loadProgress().isAllPuzzlesUnlocked
    }

    public func setUnlockCompletionHandler(_ handler: @escaping () -> Void) {
        self.onUnlockCompleted = handler
    }

    /// Opens the Kid-Safe Parental Gate with a fresh arithmetic challenge.
    public func presentParentalGate() {
        currentChallenge = ParentalChallenge.generateRandom()
        parentalGateErrorMessage = nil
        storeStatusMessage = nil
        isParentalGatePresented = true
    }

    public func dismissModals() {
        isParentalGatePresented = false
        isStoreSheetPresented = false
        parentalGateErrorMessage = nil
        storeStatusMessage = nil
    }

    /// Validates the adult's selected answer in the Parental Gate.
    @discardableResult
    public func submitParentalAnswer(_ selectedAnswer: Int) -> Bool {
        if selectedAnswer == currentChallenge.correctAnswer {
            parentalGateErrorMessage = nil
            isParentalGatePresented = false
            isStoreSheetPresented = true
            return true
        } else {
            parentalGateErrorMessage = "Oops! Try the new math question for parents."
            currentChallenge = ParentalChallenge.generateRandom()
            return false
        }
    }

    /// Executes the StoreKit 2 purchase for `"Unlock all puzzles"` (`$2.99`).
    @MainActor
    public func purchaseUnlockAll() async {
        guard !isProcessingPurchase else { return }
        isProcessingPurchase = true
        storeStatusMessage = nil

        let outcome = await storeService.purchaseUnlockAll()
        isProcessingPurchase = false
        handleStoreOutcome(outcome)
    }

    /// Executes StoreKit 2 Restore Purchases (`Transaction.currentEntitlements`).
    @MainActor
    public func restorePurchases() async {
        guard !isProcessingPurchase else { return }
        isProcessingPurchase = true
        storeStatusMessage = nil

        let outcome = await storeService.restorePurchases()
        isProcessingPurchase = false
        handleStoreOutcome(outcome)
    }

    private func handleStoreOutcome(_ outcome: StorePurchaseOutcome) {
        switch outcome {
        case .unlocked(_, let price):
            _ = progressRepository.setAllPuzzlesUnlocked(true)
            isAllUnlocked = true
            storeStatusMessage = "All 16 puzzles unlocked (\(price))!"
            isStoreSheetPresented = false
            onUnlockCompleted?()
        case .userCancelled:
            storeStatusMessage = "Purchase cancelled."
        case .pending:
            storeStatusMessage = "Purchase is pending approval."
        case .failed(let message):
            storeStatusMessage = message
        }
    }
}
