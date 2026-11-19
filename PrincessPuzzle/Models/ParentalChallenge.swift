import Foundation

/// Adult verification challenge used by the Kid-Safe Parental Gate before StoreKit purchases.
public struct ParentalChallenge: Equatable, Sendable {
    public let leftOperand: Int
    public let rightOperand: Int
    public let correctAnswer: Int
    public let choices: [Int]

    public var questionPrompt: String {
        "\(leftOperand) + \(rightOperand) = ?"
    }

    public init(leftOperand: Int, rightOperand: Int) {
        self.leftOperand = leftOperand
        self.rightOperand = rightOperand
        let sum = leftOperand + rightOperand
        self.correctAnswer = sum

        let wrong1 = sum + 3
        let wrong2 = max(1, sum - 4)
        let wrong3 = sum + 7
        var ordered = [sum, wrong1, wrong2, wrong3]
        // Deterministic rotation based on operands so unit tests and UI remain consistent
        let shift = (leftOperand + rightOperand) % ordered.count
        ordered = Array(ordered[shift...]) + Array(ordered[..<shift])
        self.choices = ordered
    }

    public static func generateRandom() -> ParentalChallenge {
        let a = Int.random(in: 12...28)
        let b = Int.random(in: 11...24)
        return ParentalChallenge(leftOperand: a, rightOperand: b)
    }
}
