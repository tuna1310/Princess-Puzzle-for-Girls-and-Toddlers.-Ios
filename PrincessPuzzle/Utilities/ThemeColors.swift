import SwiftUI
import UIKit

/// Official color palette sampled directly from the reference app screenshots (`id682756571`).
public enum ThemeColors {
    // MARK: - Meadow Landscape Colors
    public static let skyTopBlue = Color(red: 131.0 / 255.0, green: 197.0 / 255.0, blue: 242.0 / 255.0)
    public static let skyHorizonBlue = Color(red: 203.0 / 255.0, green: 233.0 / 255.0, blue: 251.0 / 255.0)
    public static let meadowHillLight = Color(red: 158.0 / 255.0, green: 201.0 / 255.0, blue: 59.0 / 255.0)
    public static let meadowHillMid = Color(red: 116.0 / 255.0, green: 163.0 / 255.0, blue: 39.0 / 255.0)
    public static let meadowHillDeep = Color(red: 85.0 / 255.0, green: 132.0 / 255.0, blue: 29.0 / 255.0)
    public static let meadowForegroundGreen = Color(red: 98.0 / 255.0, green: 145.0 / 255.0, blue: 33.0 / 255.0)
    public static let forestPineGreen = Color(red: 45.0 / 255.0, green: 109.0 / 255.0, blue: 54.0 / 255.0)
    public static let forestLeafGreen = Color(red: 68.0 / 255.0, green: 134.0 / 255.0, blue: 44.0 / 255.0)

    public static let riverBlue = Color(red: 18.0 / 255.0, green: 116.0 / 255.0, blue: 186.0 / 255.0)
    public static let riverWaveHighlight = Color(red: 104.0 / 255.0, green: 178.0 / 255.0, blue: 228.0 / 255.0)
    public static let woodenBridgeBrown = Color(red: 169.0 / 255.0, green: 123.0 / 255.0, blue: 43.0 / 255.0)
    public static let woodenBridgeDark = Color(red: 134.0 / 255.0, green: 94.0 / 255.0, blue: 26.0 / 255.0)
    public static let sandyPathGold = Color(red: 223.0 / 255.0, green: 208.0 / 255.0, blue: 107.0 / 255.0)
    public static let daisyPetalWhite = Color(red: 250.0 / 255.0, green: 252.0 / 255.0, blue: 254.0 / 255.0)
    public static let daisyCenterYellow = Color(red: 245.0 / 255.0, green: 214.0 / 255.0, blue: 24.0 / 255.0)

    // MARK: - Planet Wheel Colors
    public static let wheelOuterOverlay = Color(red: 55.0 / 255.0, green: 62.0 / 255.0, blue: 68.0 / 255.0).opacity(0.36)
    public static let planetUpperPink = Color(red: 248.0 / 255.0, green: 220.0 / 255.0, blue: 232.0 / 255.0)
    public static let planetLowerCream = Color(red: 253.0 / 255.0, green: 243.0 / 255.0, blue: 183.0 / 255.0)
    public static let planetRimPink = Color(red: 242.0 / 255.0, green: 196.0 / 255.0, blue: 212.0 / 255.0)

    // MARK: - Controls Colors
    public static let blueArrowTop = Color(red: 92.0 / 255.0, green: 152.0 / 255.0, blue: 232.0 / 255.0)
    public static let blueArrowBottom = Color(red: 27.0 / 255.0, green: 79.0 / 255.0, blue: 156.0 / 255.0)
    public static let blueArrowBorder = Color(red: 19.0 / 255.0, green: 56.0 / 255.0, blue: 115.0 / 255.0)

    public static let greenArrowTop = Color(red: 183.0 / 255.0, green: 242.0 / 255.0, blue: 106.0 / 255.0)
    public static let greenArrowBottom = Color(red: 88.0 / 255.0, green: 192.0 / 255.0, blue: 30.0 / 255.0)
    public static let greenArrowBorder = Color(red: 20.0 / 255.0, green: 114.0 / 255.0, blue: 2.0 / 255.0)

    // MARK: - UIKit Helpers for CoreGraphics Rendering
    public static func uiColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
