import SwiftUI

/// Kid-Safe Parental Gate & StoreKit 2 `"Unlock all puzzles ($2.99)"` modal overlay.
public struct ParentalGateModalView: View {
    @ObservedObject public var storeViewModel: StoreViewModel

    public init(storeViewModel: StoreViewModel) {
        self.storeViewModel = storeViewModel
    }

    public var body: some View {
        ZStack {
            if storeViewModel.isParentalGatePresented {
                Color.black.opacity(0.48)
                    .ignoresSafeArea()
                    .onTapGesture {
                        storeViewModel.dismissModals()
                    }

                parentalGateCard
                    .transition(.scale.combined(with: .opacity))
            } else if storeViewModel.isStoreSheetPresented {
                Color.black.opacity(0.48)
                    .ignoresSafeArea()
                    .onTapGesture {
                        storeViewModel.dismissModals()
                    }

                storeUnlockCard
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: storeViewModel.isParentalGatePresented)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: storeViewModel.isStoreSheetPresented)
    }

    // MARK: - 1. Kid-Safe Arithmetic Parental Gate Card

    private var parentalGateCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundColor(.pink)
                Text("Parents Only")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.35, green: 0.12, blue: 0.32))
                Spacer()
                Button {
                    storeViewModel.dismissModals()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }

            Text("Please solve this math question to continue to Unlock All Puzzles:")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(storeViewModel.currentChallenge.questionPrompt)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.78, green: 0.14, blue: 0.48))
                .padding(.vertical, 6)

            if let error = storeViewModel.parentalGateErrorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
            }

            HStack(spacing: 12) {
                ForEach(storeViewModel.currentChallenge.choices, id: \.self) { answer in
                    Button {
                        _ = storeViewModel.submitParentalAnswer(answer)
                    } label: {
                        Text("\(answer)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.pink.opacity(0.35), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.28), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - 2. StoreKit 2 Unlock All Puzzles ($2.99) & Restore Card

    private var storeUnlockCard: some View {
        VStack(spacing: 18) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text(storeViewModel.productTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.35, green: 0.12, blue: 0.32))
                Spacer()
                Button {
                    storeViewModel.dismissModals()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }

            Text("Support us and unlock all 16 physics-enabled fairy-tale princess puzzles with interactive surprise rewards!")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let status = storeViewModel.storeStatusMessage {
                Text(status)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.purple)
            }

            Button {
                Task {
                    await storeViewModel.purchaseUnlockAll()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Unlock All 16 Puzzles — \(storeViewModel.productPrice)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.93, green: 0.24, blue: 0.59), Color(red: 0.62, green: 0.12, blue: 0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(storeViewModel.isProcessingPurchase)

            Button {
                Task {
                    await storeViewModel.restorePurchases()
                }
            } label: {
                Text("Restore Previous Purchase")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.purple)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .disabled(storeViewModel.isProcessingPurchase)
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.28), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }
}
