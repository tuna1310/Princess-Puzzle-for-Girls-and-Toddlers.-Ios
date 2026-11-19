import CoreGraphics
import UIKit

/// High-resolution native CoreGraphics vector illustration engine that renders all 16 fairy-tale puzzles
/// in both full vibrant color (for the Planet Wheel and active puzzle pieces) and desaturated grayscale
/// (for the upper target silhouette board, matching `ipad_5.png` and `iphone_2..5.png`).
public final class PuzzleIllustrationRenderer {
    public static let shared = PuzzleIllustrationRenderer()

    private let cache = NSCache<NSString, UIImage>()

    public init() {
        cache.countLimit = 256
    }

    /// Renders the complete assembled illustration for a puzzle level.
    public func renderFullIllustration(
        for level: PuzzleLevel,
        size: CGSize = CGSize(width: 320, height: 360),
        grayscale: Bool = false
    ) -> UIImage {
        let key = "full_\(level.id)_\(Int(size.width))x\(Int(size.height))_\(grayscale)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let sortedPieces = level.pieces.sorted { $0.zIndex < $1.zIndex }
        let colorImage = renderer.image { ctx in
            for piece in sortedPieces {
                drawAnatomicalPart(
                    archetype: level.archetype,
                    partIndex: piece.partIndex,
                    in: ctx.cgContext,
                    canvasSize: size
                )
            }
        }

        let finalImage = grayscale ? Self.convertToGrayscaleSilhouette(colorImage) : colorImage
        cache.setObject(finalImage, forKey: key)
        return finalImage
    }

    /// Renders a single anatomical/component piece cropped to its normalized piece bounding box.
    public func renderPieceImage(
        for level: PuzzleLevel,
        piece: PuzzlePieceDefinition,
        canvasSize: CGSize = CGSize(width: 320, height: 360),
        grayscale: Bool = false
    ) -> UIImage {
        let key = "piece_\(level.id)_\(piece.id)_\(Int(canvasSize.width))x\(Int(canvasSize.height))_\(grayscale)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let pieceRect = CGRect(
            x: (piece.normalizedCenterX - piece.normalizedWidth / 2.0) * canvasSize.width,
            y: (piece.normalizedCenterY - piece.normalizedHeight / 2.0) * canvasSize.height,
            width: max(24, piece.normalizedWidth * canvasSize.width),
            height: max(24, piece.normalizedHeight * canvasSize.height)
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        format.opaque = false
        let pieceRenderer = UIGraphicsImageRenderer(size: pieceRect.size, format: format)

        let colorPiece = pieceRenderer.image { ctx in
            let cg = ctx.cgContext
            cg.translateBy(x: -pieceRect.origin.x, y: -pieceRect.origin.y)
            drawAnatomicalPart(
                archetype: level.archetype,
                partIndex: piece.partIndex,
                in: cg,
                canvasSize: canvasSize
            )
        }

        let finalImage = grayscale ? Self.convertToGrayscaleSilhouette(colorPiece) : colorPiece
        cache.setObject(finalImage, forKey: key)
        return finalImage
    }

    // MARK: - Grayscale Desaturation Filter (Matches `ipad_5.png` & `iphone_2..5.png`)

    public static func convertToGrayscaleSilhouette(_ image: UIImage) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        let width = Int(size.width * image.scale)
        let height = Int(size.height * image.scale)
        guard let sourceCG = image.cgImage, width > 0, height > 0 else { return image }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let bitmapCtx = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }

        bitmapCtx.draw(sourceCG, in: CGRect(x: 0, y: 0, width: width, height: height))

        for i in stride(from: 0, to: rawData.count, by: 4) {
            let a = rawData[i + 3]
            guard a > 0 else { continue }
            let r = Double(rawData[i])
            let g = Double(rawData[i + 1])
            let b = Double(rawData[i + 2])
            // Luminance toned to the soft medium-gray silhouette palette of ipad_5.png
            let lum = 0.299 * r + 0.587 * g + 0.114 * b
            let toned = UInt8(min(235.0, max(75.0, lum * 0.78 + 38.0)))
            rawData[i] = toned
            rawData[i + 1] = toned
            rawData[i + 2] = toned
        }

        guard let outCG = bitmapCtx.makeImage() else { return image }
        return UIImage(cgImage: outCG, scale: image.scale, orientation: .up)
    }

    // MARK: - Anatomical Vector Drawing for All 16 Archetypes

    private func drawAnatomicalPart(
        archetype: PuzzleThemeArchetype,
        partIndex: Int,
        in cg: CGContext,
        canvasSize: CGSize
    ) {
        cg.saveGState()
        defer { cg.restoreGState() }

        switch archetype {
        case .pinkCastle:
            drawPinkCastle(partIndex: partIndex, in: cg, size: canvasSize)
        case .brunettePrincess:
            drawBrunettePrincess(partIndex: partIndex, in: cg, size: canvasSize)
        case .royalPony:
            drawRoyalPony(partIndex: partIndex, in: cg, size: canvasSize)
        case .cherryIceCream:
            drawCherryIceCream(partIndex: partIndex, in: cg, size: canvasSize)
        case .blondePrincess:
            drawBlondePrincess(partIndex: partIndex, in: cg, size: canvasSize)
        case .flowerPrincess:
            drawFlowerPrincess(partIndex: partIndex, in: cg, size: canvasSize)
        case .royalKitty:
            drawRoyalKitty(partIndex: partIndex, in: cg, size: canvasSize)
        case .friendlyDragon:
            drawFriendlyDragon(partIndex: partIndex, in: cg, size: canvasSize)
        case .rainbowPalace:
            drawRainbowPalace(partIndex: partIndex, in: cg, size: canvasSize)
        case .butterflyTree:
            drawButterflyTree(partIndex: partIndex, in: cg, size: canvasSize)
        case .pumpkinCarriage:
            drawPumpkinCarriage(partIndex: partIndex, in: cg, size: canvasSize)
        case .meadowUnicorn:
            drawMeadowUnicorn(partIndex: partIndex, in: cg, size: canvasSize)
        case .royalTreasure:
            drawRoyalTreasure(partIndex: partIndex, in: cg, size: canvasSize)
        case .mermaidPrincess:
            drawMermaidPrincess(partIndex: partIndex, in: cg, size: canvasSize)
        case .rosePrincess:
            drawRosePrincess(partIndex: partIndex, in: cg, size: canvasSize)
        case .grandBallPrincess:
            drawGrandBallPrincess(partIndex: partIndex, in: cg, size: canvasSize)
        }
    }

    // MARK: - 1. Pink Fairy Castle (Matches 12 o'clock castle in iphone_1.png)

    private func drawPinkCastle(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let wallPink = ThemeColors.uiColor(232, 148, 204)
        let wallLight = ThemeColors.uiColor(244, 178, 222)
        let roofPurple = ThemeColors.uiColor(156, 24, 138)
        let flagPink = ThemeColors.uiColor(224, 34, 138)

        switch partIndex {
        case 0: // Sun & Butterfly Crest
            fillCircle(in: cg, center: CGPoint(x: w * 0.28, y: h * 0.14), radius: w * 0.06, color: ThemeColors.uiColor(248, 178, 24))
            drawButterfly(in: cg, center: CGPoint(x: w * 0.72, y: h * 0.14), scale: w * 0.08, primary: ThemeColors.uiColor(242, 102, 166))
        case 1: // Central Spire & Flag
            fillRect(in: cg, rect: CGRect(x: w * 0.42, y: h * 0.28, width: w * 0.16, height: h * 0.24), color: wallLight)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.50, y: h * 0.14), left: CGPoint(x: w * 0.39, y: h * 0.29), right: CGPoint(x: w * 0.61, y: h * 0.29), color: roofPurple)
            drawWavingFlag(in: cg, poleTop: CGPoint(x: w * 0.50, y: h * 0.08), poleBase: CGPoint(x: w * 0.50, y: h * 0.15), length: w * 0.14, color: flagPink)
        case 2: // Left Tower
            fillRect(in: cg, rect: CGRect(x: w * 0.17, y: h * 0.44, width: w * 0.16, height: h * 0.42), color: wallPink)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.25, y: h * 0.30), left: CGPoint(x: w * 0.15, y: h * 0.45), right: CGPoint(x: w * 0.35, y: h * 0.45), color: roofPurple)
            drawWavingFlag(in: cg, poleTop: CGPoint(x: w * 0.25, y: h * 0.24), poleBase: CGPoint(x: w * 0.25, y: h * 0.31), length: w * 0.11, color: flagPink)
            fillArch(in: cg, rect: CGRect(x: w * 0.23, y: h * 0.54, width: w * 0.04, height: h * 0.09), color: roofPurple)
        case 3: // Right Tower
            fillRect(in: cg, rect: CGRect(x: w * 0.67, y: h * 0.44, width: w * 0.16, height: h * 0.42), color: wallPink)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.75, y: h * 0.30), left: CGPoint(x: w * 0.65, y: h * 0.45), right: CGPoint(x: w * 0.85, y: h * 0.45), color: roofPurple)
            drawWavingFlag(in: cg, poleTop: CGPoint(x: w * 0.75, y: h * 0.24), poleBase: CGPoint(x: w * 0.75, y: h * 0.31), length: w * 0.11, color: flagPink)
            fillArch(in: cg, rect: CGRect(x: w * 0.73, y: h * 0.54, width: w * 0.04, height: h * 0.09), color: roofPurple)
        default: // Main Keep & Royal Gate
            fillRect(in: cg, rect: CGRect(x: w * 0.30, y: h * 0.50, width: w * 0.40, height: h * 0.36), color: wallPink)
            for i in 0..<5 {
                fillRect(in: cg, rect: CGRect(x: w * (0.31 + CGFloat(i) * 0.08), y: h * 0.46, width: w * 0.05, height: h * 0.05), color: wallLight)
            }
            fillArch(in: cg, rect: CGRect(x: w * 0.43, y: h * 0.68, width: w * 0.14, height: h * 0.18), color: roofPurple)
        }
    }

    // MARK: - 2. Crown Princess Mia (Matches icon_512.jpg, iphone_3.png, ipad_1.png)

    private func drawBrunettePrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 232, 228)
        let brownHair = ThemeColors.uiColor(138, 69, 41)
        let lightHair = ThemeColors.uiColor(198, 118, 72)
        let dressPink = ThemeColors.uiColor(238, 62, 150)
        let crownGold = ThemeColors.uiColor(246, 194, 34)

        switch partIndex {
        case 0: // Golden Crown & Pink Hair Flower
            drawCrown(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.04, width: w * 0.26, height: h * 0.13), color: crownGold)
            drawFlower(in: cg, center: CGPoint(x: w * 0.61, y: h * 0.15), radius: w * 0.06, petalColor: ThemeColors.uiColor(246, 102, 174), coreColor: ThemeColors.uiColor(210, 184, 212))
        case 1: // Chestnut Hair & Smiling Face
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.25, y: h * 0.13, width: w * 0.46, height: h * 0.29), radius: w * 0.16, color: brownHair)
            fillOval(in: cg, rect: CGRect(x: w * 0.33, y: h * 0.16, width: w * 0.30, height: h * 0.21), color: skin)
            fillOval(in: cg, rect: CGRect(x: w * 0.33, y: h * 0.14, width: w * 0.28, height: h * 0.08), color: lightHair)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.33, y: h * 0.16, width: w * 0.30, height: h * 0.21), eyeColor: ThemeColors.uiColor(45, 162, 224))
        case 2: // Outstretched Princess Arms
            drawArm(in: cg, from: CGPoint(x: w * 0.38, y: h * 0.41), to: CGPoint(x: w * 0.16, y: h * 0.52), thickness: w * 0.045, color: skin)
            drawArm(in: cg, from: CGPoint(x: w * 0.54, y: h * 0.41), to: CGPoint(x: w * 0.77, y: h * 0.50), thickness: w * 0.045, color: skin)
        case 3: // Pink Crown-Patterned Dress
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.46, y: h * 0.38), topWidth: w * 0.16, bottomCenter: CGPoint(x: w * 0.46, y: h * 0.70), bottomWidth: w * 0.38, color: dressPink)
            drawCrown(in: cg, rect: CGRect(x: w * 0.39, y: h * 0.49, width: w * 0.08, height: h * 0.05), color: .white)
            drawCrown(in: cg, rect: CGRect(x: w * 0.48, y: h * 0.55, width: w * 0.08, height: h * 0.05), color: crownGold)
            drawCrown(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.61, width: w * 0.10, height: h * 0.06), color: crownGold)
        case 4: // Pink Handbag & Pencils
            strokeCircle(in: cg, center: CGPoint(x: w * 0.77, y: h * 0.52), radius: w * 0.075, lineWidth: 5.0, color: dressPink)
            fillOval(in: cg, rect: CGRect(x: w * 0.75, y: h * 0.48, width: w * 0.13, height: h * 0.13), color: ThemeColors.uiColor(224, 38, 148))
            drawArm(in: cg, from: CGPoint(x: w * 0.80, y: h * 0.49), to: CGPoint(x: w * 0.76, y: h * 0.39), thickness: 5.0, color: crownGold)
            drawArm(in: cg, from: CGPoint(x: w * 0.83, y: h * 0.49), to: CGPoint(x: w * 0.79, y: h * 0.39), thickness: 5.0, color: ThemeColors.uiColor(86, 188, 236))
        default: // Princess Legs & Slippers
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.41, y: h * 0.69), bottom: CGPoint(x: w * 0.44, y: h * 0.92), legColor: .white, shoeColor: ThemeColors.uiColor(124, 124, 128))
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.51, y: h * 0.69), bottom: CGPoint(x: w * 0.64, y: h * 0.90), legColor: skin, shoeColor: dressPink)
        }
    }

    // MARK: - 3. Royal Pink Pony (Matches iphone_2.png, ipad_2.png)

    private func drawRoyalPony(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let ponyPink = ThemeColors.uiColor(249, 182, 212)
        let maneHotPink = ThemeColors.uiColor(234, 24, 122)
        let saddleBlue = ThemeColors.uiColor(114, 206, 222)
        let hoofPurple = ThemeColors.uiColor(98, 28, 134)

        switch partIndex {
        case 0: // Pony Head, Mane & Flower
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.54, y: h * 0.14, width: w * 0.18, height: h * 0.28), radius: w * 0.08, color: maneHotPink)
            fillOval(in: cg, rect: CGRect(x: w * 0.60, y: h * 0.12, width: w * 0.28, height: h * 0.15), color: ponyPink)
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.58, y: h * 0.20, width: w * 0.16, height: h * 0.22), radius: w * 0.07, color: ponyPink)
            fillCircle(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.18), radius: w * 0.032, color: ThemeColors.uiColor(38, 146, 224))
            fillCircle(in: cg, center: CGPoint(x: w * 0.745, y: h * 0.18), radius: w * 0.015, color: .black)
            drawFlower(in: cg, center: CGPoint(x: w * 0.80, y: h * 0.29), radius: w * 0.06, petalColor: ThemeColors.uiColor(246, 114, 182), coreColor: maneHotPink)
        case 1: // Front Chest & Forelegs
            fillOval(in: cg, rect: CGRect(x: w * 0.52, y: h * 0.34, width: w * 0.24, height: h * 0.20), color: ponyPink)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.64, y: h * 0.50), bottom: CGPoint(x: w * 0.67, y: h * 0.78), legColor: ponyPink, shoeColor: hoofPurple)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.71, y: h * 0.50), bottom: CGPoint(x: w * 0.73, y: h * 0.77), legColor: ponyPink, shoeColor: hoofPurple)
        case 2: // Turquoise Saddle & Stirrup
            fillOval(in: cg, rect: CGRect(x: w * 0.40, y: h * 0.34, width: w * 0.20, height: h * 0.14), color: saddleBlue)
            drawArm(in: cg, from: CGPoint(x: w * 0.49, y: h * 0.46), to: CGPoint(x: w * 0.50, y: h * 0.62), thickness: 3.5, color: ThemeColors.uiColor(38, 146, 212))
            strokeCircle(in: cg, center: CGPoint(x: w * 0.50, y: h * 0.64), radius: w * 0.025, lineWidth: 3.0, color: ThemeColors.uiColor(38, 146, 212))
        case 3: // Pony Back & Rump
            fillOval(in: cg, rect: CGRect(x: w * 0.25, y: h * 0.34, width: w * 0.28, height: h * 0.22), color: ponyPink)
        case 4: // Pink Hind Legs & Hooves
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.31, y: h * 0.52), bottom: CGPoint(x: w * 0.36, y: h * 0.85), legColor: ponyPink, shoeColor: hoofPurple)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.39, y: h * 0.51), bottom: CGPoint(x: w * 0.42, y: h * 0.78), legColor: ThemeColors.uiColor(238, 142, 188), shoeColor: hoofPurple)
        default: // Flowing Hot-Pink Tail
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.08, y: h * 0.34, width: w * 0.18, height: h * 0.36), radius: w * 0.09, color: maneHotPink)
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.12, y: h * 0.38, width: w * 0.11, height: h * 0.28), radius: w * 0.05, color: ThemeColors.uiColor(246, 98, 172))
        }
    }

    // MARK: - 4. Royal Cherry Ice Cream (Matches iphone_4.png)

    private func drawCherryIceCream(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let coneCream = ThemeColors.uiColor(248, 218, 194)
        let coneStripe = ThemeColors.uiColor(234, 188, 156)
        let scoopPink = ThemeColors.uiColor(234, 88, 148)
        let scoopLight = ThemeColors.uiColor(251, 212, 224)
        let leafGreen = ThemeColors.uiColor(186, 214, 54)
        let cherryRed = ThemeColors.uiColor(218, 22, 52)

        switch partIndex {
        case 0: // Twin Red Cherries & Stems
            drawArm(in: cg, from: CGPoint(x: w * 0.48, y: h * 0.20), to: CGPoint(x: w * 0.64, y: h * 0.08), thickness: 2.5, color: ThemeColors.uiColor(96, 114, 42))
            drawArm(in: cg, from: CGPoint(x: w * 0.56, y: h * 0.24), to: CGPoint(x: w * 0.64, y: h * 0.08), thickness: 2.5, color: ThemeColors.uiColor(96, 114, 42))
            fillCircle(in: cg, center: CGPoint(x: w * 0.48, y: h * 0.20), radius: w * 0.045, color: cherryRed)
            fillCircle(in: cg, center: CGPoint(x: w * 0.56, y: h * 0.24), radius: w * 0.045, color: cherryRed)
        case 1: // Pink & Cream Swirled Scoop
            fillOval(in: cg, rect: CGRect(x: w * 0.34, y: h * 0.18, width: w * 0.32, height: h * 0.28), color: scoopLight)
            fillOval(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.26, width: w * 0.28, height: h * 0.18), color: scoopPink)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.54, y: h * 0.08), left: CGPoint(x: w * 0.38, y: h * 0.26), right: CGPoint(x: w * 0.62, y: h * 0.26), color: scoopLight)
        case 2: // Left Mint Leaf Fan
            fillOval(in: cg, rect: CGRect(x: w * 0.16, y: h * 0.22, width: w * 0.22, height: h * 0.12), color: leafGreen)
            fillOval(in: cg, rect: CGRect(x: w * 0.14, y: h * 0.30, width: w * 0.22, height: h * 0.12), color: leafGreen)
        case 3: // Right Mint Leaf Fan
            fillOval(in: cg, rect: CGRect(x: w * 0.62, y: h * 0.24, width: w * 0.22, height: h * 0.12), color: leafGreen)
            fillOval(in: cg, rect: CGRect(x: w * 0.64, y: h * 0.32, width: w * 0.22, height: h * 0.12), color: leafGreen)
        case 4: // Upper Waffle Cone Wrapper
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.48, y: h * 0.46), topWidth: w * 0.24, bottomCenter: CGPoint(x: w * 0.47, y: h * 0.68), bottomWidth: w * 0.15, color: coneCream)
            drawArm(in: cg, from: CGPoint(x: w * 0.38, y: h * 0.53), to: CGPoint(x: w * 0.58, y: h * 0.55), thickness: 4.0, color: coneStripe)
            drawArm(in: cg, from: CGPoint(x: w * 0.40, y: h * 0.61), to: CGPoint(x: w * 0.55, y: h * 0.63), thickness: 4.0, color: coneStripe)
        default: // Lower Waffle Cone Tip
            fillTriangle(in: cg, top: CGPoint(x: w * 0.44, y: h * 0.92), left: CGPoint(x: w * 0.40, y: h * 0.68), right: CGPoint(x: w * 0.54, y: h * 0.68), color: coneCream)
        }
    }

    // MARK: - 5. Ruffle Dress Princess (Matches iphone_5.png, ipad_4.png)

    private func drawBlondePrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 224, 214)
        let blonde = ThemeColors.uiColor(246, 196, 36)
        let hotPink = ThemeColors.uiColor(234, 36, 138)
        let lightPink = ThemeColors.uiColor(248, 174, 208)
        let flowerBlue = ThemeColors.uiColor(84, 192, 232)

        switch partIndex {
        case 0: // Pink Jeweled Crown
            drawCrown(in: cg, rect: CGRect(x: w * 0.39, y: h * 0.04, width: w * 0.24, height: h * 0.12), color: hotPink)
        case 1: // Golden Blonde Hair & Face
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.30, y: h * 0.13, width: w * 0.40, height: h * 0.24), radius: w * 0.12, color: blonde)
            fillOval(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.16, width: w * 0.28, height: h * 0.19), color: skin)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.36, y: h * 0.16, width: w * 0.28, height: h * 0.19), eyeColor: flowerBlue)
        case 2: // Striped Bodice & Arms
            drawArm(in: cg, from: CGPoint(x: w * 0.40, y: h * 0.39), to: CGPoint(x: w * 0.18, y: h * 0.43), thickness: w * 0.04, color: skin)
            drawArm(in: cg, from: CGPoint(x: w * 0.60, y: h * 0.39), to: CGPoint(x: w * 0.82, y: h * 0.46), thickness: w * 0.04, color: skin)
            fillRect(in: cg, rect: CGRect(x: w * 0.41, y: h * 0.36, width: w * 0.18, height: h * 0.15), color: lightPink)
            for i in 0..<3 {
                fillRect(in: cg, rect: CGRect(x: w * 0.41, y: h * (0.38 + CGFloat(i) * 0.045), width: w * 0.18, height: h * 0.02), color: hotPink)
            }
        case 3: // Blue Waist Flower Belt
            drawFlower(in: cg, center: CGPoint(x: w * 0.52, y: h * 0.49), radius: w * 0.065, petalColor: flowerBlue, coreColor: .white)
        case 4: // Hot-Pink Wavy Overskirt
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.50), topWidth: w * 0.22, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.69), bottomWidth: w * 0.56, color: hotPink)
        case 5: // Light-Pink Underskirt Ruffle
            for i in 0..<7 {
                let rx = w * (0.26 + CGFloat(i) * 0.08)
                fillOval(in: cg, rect: CGRect(x: rx - w * 0.04, y: h * 0.62, width: w * 0.08, height: h * 0.12), color: lightPink)
            }
        default: // Legs & Blue Flower Shoes
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.44, y: h * 0.71), bottom: CGPoint(x: w * 0.42, y: h * 0.90), legColor: skin, shoeColor: flowerBlue)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.56, y: h * 0.71), bottom: CGPoint(x: w * 0.64, y: h * 0.89), legColor: skin, shoeColor: flowerBlue)
        }
    }

    // MARK: - 6. Flower Bouquet Princess (Matches ipad_5.png)

    private func drawFlowerPrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 228, 220)
        let yellowHair = ThemeColors.uiColor(246, 206, 42)
        let magenta = ThemeColors.uiColor(232, 34, 128)
        let lightMagenta = ThemeColors.uiColor(246, 128, 184)

        switch partIndex {
        case 0: // Pearl Tiara
            drawCrown(in: cg, rect: CGRect(x: w * 0.35, y: h * 0.05, width: w * 0.24, height: h * 0.10), color: ThemeColors.uiColor(244, 192, 42))
        case 1: // Wavy Golden Hair
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.24, y: h * 0.12, width: w * 0.46, height: h * 0.28), radius: w * 0.14, color: yellowHair)
        case 2: // Smiling Princess Face
            fillOval(in: cg, rect: CGRect(x: w * 0.35, y: h * 0.15, width: w * 0.24, height: h * 0.19), color: skin)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.35, y: h * 0.15, width: w * 0.24, height: h * 0.19), eyeColor: ThemeColors.uiColor(54, 158, 214))
        case 3: // Daisy-Belted Bodice
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.47, y: h * 0.36), topWidth: w * 0.16, bottomCenter: CGPoint(x: w * 0.47, y: h * 0.49), bottomWidth: w * 0.20, color: lightMagenta)
            for i in 0..<4 {
                drawFlower(in: cg, center: CGPoint(x: w * (0.39 + CGFloat(i) * 0.053), y: h * 0.47), radius: w * 0.025, petalColor: .white, coreColor: yellowHair)
            }
        case 4: // Left Magenta Skirt Panel
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.41, y: h * 0.49), topWidth: w * 0.10, bottomCenter: CGPoint(x: w * 0.35, y: h * 0.73), bottomWidth: w * 0.22, color: magenta)
        case 5: // Right Magenta Skirt Panel
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.53, y: h * 0.49), topWidth: w * 0.10, bottomCenter: CGPoint(x: w * 0.59, y: h * 0.73), bottomWidth: w * 0.22, color: lightMagenta)
        case 6: // Right Arm & Flower Basket
            drawArm(in: cg, from: CGPoint(x: w * 0.56, y: h * 0.39), to: CGPoint(x: w * 0.74, y: h * 0.48), thickness: w * 0.038, color: skin)
            fillOval(in: cg, rect: CGRect(x: w * 0.68, y: h * 0.42, width: w * 0.18, height: h * 0.16), color: ThemeColors.uiColor(158, 102, 52))
            drawFlower(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.44), radius: w * 0.04, petalColor: .white, coreColor: yellowHair)
            drawFlower(in: cg, center: CGPoint(x: w * 0.80, y: h * 0.48), radius: w * 0.04, petalColor: .white, coreColor: magenta)
        default: // Left Arm & Dancing Slippers
            drawArm(in: cg, from: CGPoint(x: w * 0.38, y: h * 0.39), to: CGPoint(x: w * 0.20, y: h * 0.48), thickness: w * 0.038, color: skin)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.41, y: h * 0.72), bottom: CGPoint(x: w * 0.36, y: h * 0.90), legColor: skin, shoeColor: ThemeColors.uiColor(94, 196, 232))
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.52, y: h * 0.72), bottom: CGPoint(x: w * 0.57, y: h * 0.91), legColor: skin, shoeColor: ThemeColors.uiColor(94, 196, 232))
        }
    }

    // MARK: - 7. Princess White Kitty (Matches 3:45 on wheel in iphone_1.png)

    private func drawRoyalKitty(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let kittyWhite = ThemeColors.uiColor(246, 242, 248)
        let kittyPink = ThemeColors.uiColor(238, 104, 174)
        let gold = ThemeColors.uiColor(246, 196, 42)

        switch partIndex {
        case 0: // Golden Kitty Crown
            drawCrown(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.07, width: w * 0.24, height: h * 0.12), color: gold)
        case 1: // White Kitty Head & Whiskers
            fillTriangle(in: cg, top: CGPoint(x: w * 0.34, y: h * 0.16), left: CGPoint(x: w * 0.30, y: h * 0.28), right: CGPoint(x: w * 0.42, y: h * 0.24), color: kittyWhite)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.66, y: h * 0.16), left: CGPoint(x: w * 0.58, y: h * 0.24), right: CGPoint(x: w * 0.70, y: h * 0.28), color: kittyWhite)
            fillOval(in: cg, rect: CGRect(x: w * 0.32, y: h * 0.20, width: w * 0.36, height: h * 0.24), color: kittyWhite)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.34, y: h * 0.21, width: w * 0.32, height: h * 0.22), eyeColor: ThemeColors.uiColor(64, 168, 224))
        case 2: // White Fairy Gown & Daisy
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.44), topWidth: w * 0.22, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.76), bottomWidth: w * 0.44, color: kittyWhite)
            drawFlower(in: cg, center: CGPoint(x: w * 0.50, y: h * 0.58), radius: w * 0.055, petalColor: .white, coreColor: gold)
        case 3: // Pink Royal Kitty Purse
            fillOval(in: cg, rect: CGRect(x: w * 0.68, y: h * 0.48, width: w * 0.16, height: h * 0.16), color: kittyPink)
        default: // Fluffy White Tail & Paws
            fillOval(in: cg, rect: CGRect(x: w * 0.24, y: h * 0.72, width: w * 0.20, height: h * 0.12), color: kittyWhite)
            fillCircle(in: cg, center: CGPoint(x: w * 0.44, y: h * 0.84), radius: w * 0.045, color: kittyWhite)
            fillCircle(in: cg, center: CGPoint(x: w * 0.56, y: h * 0.84), radius: w * 0.045, color: kittyWhite)
        }
    }

    // MARK: - 8. Friendly Golden Dragon (Matches 4:45 on wheel in iphone_1.png)

    private func drawFriendlyDragon(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let dragonGold = ThemeColors.uiColor(196, 204, 48)
        let wingOrange = ThemeColors.uiColor(246, 178, 34)
        let hornRed = ThemeColors.uiColor(198, 52, 34)

        switch partIndex {
        case 0: // Smiling Dragon Head & Horns
            fillOval(in: cg, rect: CGRect(x: w * 0.14, y: h * 0.16, width: w * 0.26, height: h * 0.18), color: dragonGold)
            fillTriangle(in: cg, top: CGPoint(x: w * 0.22, y: h * 0.10), left: CGPoint(x: w * 0.20, y: h * 0.18), right: CGPoint(x: w * 0.26, y: h * 0.18), color: hornRed)
            fillCircle(in: cg, center: CGPoint(x: w * 0.24, y: h * 0.22), radius: w * 0.025, color: .black)
        case 1: // Left Orange Wing
            fillTriangle(in: cg, top: CGPoint(x: w * 0.24, y: h * 0.28), left: CGPoint(x: w * 0.48, y: h * 0.34), right: CGPoint(x: w * 0.38, y: h * 0.50), color: wingOrange)
        case 2: // Right Orange Wing
            fillTriangle(in: cg, top: CGPoint(x: w * 0.78, y: h * 0.20), left: CGPoint(x: w * 0.52, y: h * 0.36), right: CGPoint(x: w * 0.72, y: h * 0.48), color: wingOrange)
        case 3: // Scaled Golden Body
            fillOval(in: cg, rect: CGRect(x: w * 0.32, y: h * 0.38, width: w * 0.32, height: h * 0.28), color: dragonGold)
        case 4: // Curled Spiral Tail
            strokeCircle(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.62), radius: w * 0.11, lineWidth: 14.0, color: dragonGold)
        case 5: // Front Dragon Claws
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.36, y: h * 0.62), bottom: CGPoint(x: w * 0.32, y: h * 0.84), legColor: dragonGold, shoeColor: hornRed)
        default: // Hind Dragon Legs
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.54, y: h * 0.64), bottom: CGPoint(x: w * 0.60, y: h * 0.86), legColor: dragonGold, shoeColor: hornRed)
        }
    }

    // MARK: - 9. Enchanted Rainbow Palace (Matches 6:30 on wheel in iphone_1.png)

    private func drawRainbowPalace(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let turquoise = ThemeColors.uiColor(64, 186, 202)
        let goldWall = ThemeColors.uiColor(246, 188, 38)
        let crimson = ThemeColors.uiColor(218, 42, 48)

        switch partIndex {
        case 0: // Golden Butterfly & Banner
            drawButterfly(in: cg, center: CGPoint(x: w * 0.50, y: h * 0.12), scale: w * 0.09, primary: goldWall)
        case 1: // Left Crimson Spire
            fillTriangle(in: cg, top: CGPoint(x: w * 0.24, y: h * 0.18), left: CGPoint(x: w * 0.16, y: h * 0.40), right: CGPoint(x: w * 0.32, y: h * 0.40), color: crimson)
        case 2: // Center Golden Spire
            fillTriangle(in: cg, top: CGPoint(x: w * 0.50, y: h * 0.14), left: CGPoint(x: w * 0.40, y: h * 0.40), right: CGPoint(x: w * 0.60, y: h * 0.40), color: goldWall)
        case 3: // Right Crimson Spire
            fillTriangle(in: cg, top: CGPoint(x: w * 0.76, y: h * 0.18), left: CGPoint(x: w * 0.68, y: h * 0.40), right: CGPoint(x: w * 0.84, y: h * 0.40), color: crimson)
        case 4: // Central Turquoise Tower
            fillRect(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.38, width: w * 0.28, height: h * 0.42), color: turquoise)
        case 5: // Left Patterned Gold Wing
            fillRect(in: cg, rect: CGRect(x: w * 0.14, y: h * 0.44, width: w * 0.22, height: h * 0.36), color: goldWall)
            fillCircle(in: cg, center: CGPoint(x: w * 0.25, y: h * 0.60), radius: w * 0.06, color: crimson)
        case 6: // Right Patterned Gold Wing
            fillRect(in: cg, rect: CGRect(x: w * 0.64, y: h * 0.44, width: w * 0.22, height: h * 0.36), color: goldWall)
            fillCircle(in: cg, center: CGPoint(x: w * 0.75, y: h * 0.60), radius: w * 0.06, color: crimson)
        default: // Crimson Striped Royal Gate
            fillArch(in: cg, rect: CGRect(x: w * 0.42, y: h * 0.64, width: w * 0.16, height: h * 0.22), color: crimson)
        }
    }

    // MARK: - 10. Magic Blossom & Butterfly (Matches 1:00 on wheel in iphone_1.png)

    private func drawButterflyTree(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let leafOuter = ThemeColors.uiColor(168, 212, 48)
        let leafInner = ThemeColors.uiColor(102, 162, 34)
        let trunkRed = ThemeColors.uiColor(168, 44, 32)

        switch partIndex {
        case 0: // Pink Royal Butterfly
            drawButterfly(in: cg, center: CGPoint(x: w * 0.66, y: h * 0.16), scale: w * 0.10, primary: ThemeColors.uiColor(242, 96, 162))
        case 1: // Center Spiral Green Canopy
            fillCircle(in: cg, center: CGPoint(x: w * 0.50, y: h * 0.33), radius: w * 0.15, color: leafOuter)
            fillCircle(in: cg, center: CGPoint(x: w * 0.50, y: h * 0.33), radius: w * 0.09, color: leafInner)
        case 2: // Left Spiral Green Canopy
            fillCircle(in: cg, center: CGPoint(x: w * 0.24, y: h * 0.42), radius: w * 0.13, color: leafOuter)
            fillCircle(in: cg, center: CGPoint(x: w * 0.24, y: h * 0.42), radius: w * 0.07, color: leafInner)
        case 3: // Right Spiral Green Canopy
            fillCircle(in: cg, center: CGPoint(x: w * 0.76, y: h * 0.42), radius: w * 0.13, color: leafOuter)
            fillCircle(in: cg, center: CGPoint(x: w * 0.76, y: h * 0.42), radius: w * 0.07, color: leafInner)
        case 4: // Red Fairy Tree Trunk
            fillRect(in: cg, rect: CGRect(x: w * 0.45, y: h * 0.46, width: w * 0.10, height: h * 0.36), color: trunkRed)
            drawArm(in: cg, from: CGPoint(x: w * 0.48, y: h * 0.58), to: CGPoint(x: w * 0.26, y: h * 0.46), thickness: 10.0, color: trunkRed)
            drawArm(in: cg, from: CGPoint(x: w * 0.52, y: h * 0.58), to: CGPoint(x: w * 0.74, y: h * 0.46), thickness: 10.0, color: trunkRed)
        default: // Meadow Blossom Base
            fillOval(in: cg, rect: CGRect(x: w * 0.24, y: h * 0.78, width: w * 0.52, height: h * 0.12), color: leafInner)
            drawFlower(in: cg, center: CGPoint(x: w * 0.38, y: h * 0.83), radius: w * 0.045, petalColor: .white, coreColor: ThemeColors.uiColor(246, 204, 34))
            drawFlower(in: cg, center: CGPoint(x: w * 0.62, y: h * 0.83), radius: w * 0.045, petalColor: ThemeColors.uiColor(246, 114, 182), coreColor: .white)
        }
    }

    // MARK: - 11. Royal Pumpkin Carriage

    private func drawPumpkinCarriage(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let coachPink = ThemeColors.uiColor(244, 122, 184)
        let gold = ThemeColors.uiColor(246, 194, 38)
        let windowBlue = ThemeColors.uiColor(142, 218, 246)

        switch partIndex {
        case 0: // Golden Crown Coach Roof
            drawCrown(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.10, width: w * 0.28, height: h * 0.14), color: gold)
        case 1: // Pink Pumpkin Coach Body
            fillOval(in: cg, rect: CGRect(x: w * 0.22, y: h * 0.26, width: w * 0.56, height: h * 0.38), color: coachPink)
        case 2: // Royal Window & Curtains
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.34, width: w * 0.24, height: h * 0.18), radius: 12, color: windowBlue)
        case 3: // Coachman Golden Lantern
            fillOval(in: cg, rect: CGRect(x: w * 0.74, y: h * 0.28, width: w * 0.12, height: h * 0.14), color: gold)
        case 4: // Velvet Entry Steps
            fillRect(in: cg, rect: CGRect(x: w * 0.42, y: h * 0.62, width: w * 0.16, height: h * 0.12), color: ThemeColors.uiColor(184, 34, 118))
        case 5: // Left Golden Spoke Wheel
            strokeCircle(in: cg, center: CGPoint(x: w * 0.26, y: h * 0.76), radius: w * 0.12, lineWidth: 8.0, color: gold)
            fillCircle(in: cg, center: CGPoint(x: w * 0.26, y: h * 0.76), radius: w * 0.04, color: coachPink)
        default: // Right Golden Spoke Wheel
            strokeCircle(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.76), radius: w * 0.12, lineWidth: 8.0, color: gold)
            fillCircle(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.76), radius: w * 0.04, color: coachPink)
        }
    }

    // MARK: - 12. Magic Meadow Unicorn

    private func drawMeadowUnicorn(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let unicornWhite = ThemeColors.uiColor(250, 246, 254)
        let lavender = ThemeColors.uiColor(194, 134, 238)
        let gold = ThemeColors.uiColor(246, 198, 42)
        let pink = ThemeColors.uiColor(242, 92, 168)

        switch partIndex {
        case 0: // Golden Spiral Horn & Crown
            fillTriangle(in: cg, top: CGPoint(x: w * 0.84, y: h * 0.05), left: CGPoint(x: w * 0.68, y: h * 0.20), right: CGPoint(x: w * 0.76, y: h * 0.22), color: gold)
        case 1: // Unicorn Head & Lavender Mane
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.54, y: h * 0.18, width: w * 0.16, height: h * 0.24), radius: 14, color: lavender)
            fillOval(in: cg, rect: CGRect(x: w * 0.60, y: h * 0.18, width: w * 0.26, height: h * 0.16), color: unicornWhite)
            fillCircle(in: cg, center: CGPoint(x: w * 0.74, y: h * 0.24), radius: w * 0.025, color: ThemeColors.uiColor(124, 54, 198))
        case 2: // Floral Neck Garland
            drawFlower(in: cg, center: CGPoint(x: w * 0.60, y: h * 0.44), radius: w * 0.055, petalColor: pink, coreColor: gold)
        case 3: // White Body & Star Flank
            fillOval(in: cg, rect: CGRect(x: w * 0.26, y: h * 0.36, width: w * 0.38, height: h * 0.22), color: unicornWhite)
            fillCircle(in: cg, center: CGPoint(x: w * 0.38, y: h * 0.46), radius: w * 0.035, color: gold)
        case 4: // Front Legs & Golden Hooves
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.62, y: h * 0.54), bottom: CGPoint(x: w * 0.65, y: h * 0.84), legColor: unicornWhite, shoeColor: gold)
        case 5: // Hind Legs & Golden Hooves
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.34, y: h * 0.54), bottom: CGPoint(x: w * 0.36, y: h * 0.84), legColor: unicornWhite, shoeColor: gold)
        default: // Rainbow Flowing Tail
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.08, y: h * 0.36, width: w * 0.16, height: h * 0.34), radius: 18, color: pink)
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.12, y: h * 0.40, width: w * 0.10, height: h * 0.28), radius: 14, color: lavender)
        }
    }

    // MARK: - 13. Crystal Tiara & Wand

    private func drawRoyalTreasure(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let gold = ThemeColors.uiColor(246, 196, 38)
        let ruby = ThemeColors.uiColor(236, 44, 128)
        let crystalBlue = ThemeColors.uiColor(124, 214, 246)

        switch partIndex {
        case 0: // Pink Diamond Center Jewel
            fillOval(in: cg, rect: CGRect(x: w * 0.42, y: h * 0.10, width: w * 0.16, height: h * 0.16), color: ruby)
        case 1: // Golden Royal Tiara Base
            drawCrown(in: cg, rect: CGRect(x: w * 0.24, y: h * 0.18, width: w * 0.52, height: h * 0.20), color: gold)
        case 2: // Magic Star Fairy Wand
            drawArm(in: cg, from: CGPoint(x: w * 0.18, y: h * 0.70), to: CGPoint(x: w * 0.36, y: h * 0.46), thickness: 8.0, color: gold)
            drawFlower(in: cg, center: CGPoint(x: w * 0.36, y: h * 0.46), radius: w * 0.08, petalColor: gold, coreColor: ruby)
        case 3: // Ruby Heart Royal Locket
            fillCircle(in: cg, center: CGPoint(x: w * 0.72, y: h * 0.54), radius: w * 0.11, color: ruby)
            strokeCircle(in: cg, center: CGPoint(x: w * 0.72, y: h * 0.54), radius: w * 0.11, lineWidth: 5.0, color: gold)
        case 4: // Left Crystal Glass Slipper
            fillOval(in: cg, rect: CGRect(x: w * 0.22, y: h * 0.74, width: w * 0.24, height: h * 0.12), color: crystalBlue)
        default: // Right Crystal Glass Slipper
            fillOval(in: cg, rect: CGRect(x: w * 0.54, y: h * 0.74, width: w * 0.24, height: h * 0.12), color: crystalBlue)
        }
    }

    // MARK: - 14. River Mermaid Princess

    private func drawMermaidPrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 228, 218)
        let coralHair = ThemeColors.uiColor(238, 86, 112)
        let tailTurquoise = ThemeColors.uiColor(54, 198, 194)
        let gold = ThemeColors.uiColor(246, 196, 38)

        switch partIndex {
        case 0: // Golden Seashell Tiara
            drawCrown(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.04, width: w * 0.24, height: h * 0.11), color: gold)
        case 1: // Flowing Coral Hair
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.26, y: h * 0.12, width: w * 0.48, height: h * 0.28), radius: w * 0.14, color: coralHair)
        case 2: // Smiling Mermaid Face
            fillOval(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.15, width: w * 0.28, height: h * 0.19), color: skin)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.36, y: h * 0.15, width: w * 0.28, height: h * 0.19), eyeColor: tailTurquoise)
        case 3: // Pearl Seashell Bodice
            fillOval(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.37, width: w * 0.11, height: h * 0.10), color: ThemeColors.uiColor(214, 118, 232))
            fillOval(in: cg, rect: CGRect(x: w * 0.51, y: h * 0.37, width: w * 0.11, height: h * 0.10), color: ThemeColors.uiColor(214, 118, 232))
        case 4: // Waving Mermaid Arms
            drawArm(in: cg, from: CGPoint(x: w * 0.38, y: h * 0.40), to: CGPoint(x: w * 0.18, y: h * 0.45), thickness: w * 0.04, color: skin)
            drawArm(in: cg, from: CGPoint(x: w * 0.62, y: h * 0.40), to: CGPoint(x: w * 0.82, y: h * 0.45), thickness: w * 0.04, color: skin)
        case 5: // Upper Turquoise Scaled Tail
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.49), topWidth: w * 0.22, bottomCenter: CGPoint(x: w * 0.48, y: h * 0.75), bottomWidth: w * 0.14, color: tailTurquoise)
        case 6: // Lower Shimmering Tail Fin
            fillOval(in: cg, rect: CGRect(x: w * 0.44, y: h * 0.73, width: w * 0.28, height: h * 0.16), color: ThemeColors.uiColor(94, 224, 214))
        default: // Pink Starfish Friend
            drawFlower(in: cg, center: CGPoint(x: w * 0.24, y: h * 0.74), radius: w * 0.07, petalColor: ThemeColors.uiColor(246, 112, 168), coreColor: gold)
        }
    }

    // MARK: - 15. Sleeping Rose Princess

    private func drawRosePrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 228, 220)
        let auburnHair = ThemeColors.uiColor(168, 58, 42)
        let rosePink = ThemeColors.uiColor(232, 48, 124)
        let capePurple = ThemeColors.uiColor(152, 42, 148)
        let gold = ThemeColors.uiColor(246, 196, 38)

        switch partIndex {
        case 0: // Golden Rose Crown
            drawCrown(in: cg, rect: CGRect(x: w * 0.38, y: h * 0.04, width: w * 0.24, height: h * 0.11), color: gold)
        case 1: // Long Auburn Curls
            fillRoundedRect(in: cg, rect: CGRect(x: w * 0.26, y: h * 0.12, width: w * 0.48, height: h * 0.28), radius: w * 0.14, color: auburnHair)
        case 2: // Smiling Princess Face
            fillOval(in: cg, rect: CGRect(x: w * 0.37, y: h * 0.15, width: w * 0.26, height: h * 0.19), color: skin)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.37, y: h * 0.15, width: w * 0.26, height: h * 0.19), eyeColor: ThemeColors.uiColor(64, 158, 222))
        case 3: // Rose Corset Bodice
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.35), topWidth: w * 0.18, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.51), bottomWidth: w * 0.22, color: rosePink)
        case 4: // Flowing Velvet Royal Cape
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.36), topWidth: w * 0.26, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.70), bottomWidth: w * 0.62, color: capePurple)
        case 5: // Layered Rose Gown Skirt
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.51), topWidth: w * 0.22, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.80), bottomWidth: w * 0.48, color: rosePink)
        case 6: // Blooming Rose Bouquet
            drawFlower(in: cg, center: CGPoint(x: w * 0.76, y: h * 0.48), radius: w * 0.075, petalColor: rosePink, coreColor: gold)
        default: // Golden Rose Slippers
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.44, y: h * 0.79), bottom: CGPoint(x: w * 0.42, y: h * 0.91), legColor: skin, shoeColor: gold)
            drawLegWithShoe(in: cg, top: CGPoint(x: w * 0.56, y: h * 0.79), bottom: CGPoint(x: w * 0.58, y: h * 0.91), legColor: skin, shoeColor: gold)
        }
    }

    // MARK: - 16. Grand Royal Ball Princess

    private func drawGrandBallPrincess(partIndex: Int, in cg: CGContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let skin = ThemeColors.uiColor(253, 228, 220)
        let hair = ThemeColors.uiColor(118, 56, 36)
        let gold = ThemeColors.uiColor(246, 196, 38)
        let magenta = ThemeColors.uiColor(228, 34, 134)

        switch partIndex {
        case 0: // Diamond Star Tiara
            drawCrown(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.03, width: w * 0.28, height: h * 0.12), color: gold)
        case 1: // Royal Updo Hairstyle
            fillOval(in: cg, rect: CGRect(x: w * 0.30, y: h * 0.12, width: w * 0.40, height: h * 0.24), color: hair)
        case 2: // Princess Face & Ruby Necklace
            fillOval(in: cg, rect: CGRect(x: w * 0.37, y: h * 0.16, width: w * 0.26, height: h * 0.18), color: skin)
            drawPrincessEyesAndSmile(in: cg, faceRect: CGRect(x: w * 0.37, y: h * 0.16, width: w * 0.26, height: h * 0.18), eyeColor: ThemeColors.uiColor(45, 162, 224))
        case 3: // Embroidered Gold Bodice
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.35), topWidth: w * 0.18, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.50), bottomWidth: w * 0.22, color: gold)
        case 4: // Left Arm & Royal Feather Fan
            drawArm(in: cg, from: CGPoint(x: w * 0.40, y: h * 0.38), to: CGPoint(x: w * 0.20, y: h * 0.46), thickness: w * 0.04, color: skin)
            fillOval(in: cg, rect: CGRect(x: w * 0.12, y: h * 0.36, width: w * 0.16, height: h * 0.14), color: magenta)
        case 5: // Right Gloved Arm & Scepter
            drawArm(in: cg, from: CGPoint(x: w * 0.60, y: h * 0.38), to: CGPoint(x: w * 0.80, y: h * 0.46), thickness: w * 0.04, color: skin)
            fillCircle(in: cg, center: CGPoint(x: w * 0.82, y: h * 0.40), radius: w * 0.045, color: gold)
        case 6: // Magenta Ballgown Peplum
            fillOval(in: cg, rect: CGRect(x: w * 0.24, y: h * 0.48, width: w * 0.52, height: h * 0.18), color: magenta)
        case 7: // Golden Layered Ballgown Skirt
            fillTrapezoid(in: cg, topCenter: CGPoint(x: w * 0.50, y: h * 0.58), topWidth: w * 0.34, bottomCenter: CGPoint(x: w * 0.50, y: h * 0.84), bottomWidth: w * 0.60, color: gold)
        default: // Crystal Dancing Shoes
            fillOval(in: cg, rect: CGRect(x: w * 0.36, y: h * 0.84, width: w * 0.10, height: h * 0.07), color: ThemeColors.uiColor(118, 214, 246))
            fillOval(in: cg, rect: CGRect(x: w * 0.54, y: h * 0.84, width: w * 0.10, height: h * 0.07), color: ThemeColors.uiColor(118, 214, 246))
        }
    }

    // MARK: - CoreGraphics Vector Primitives

    private func fillRect(in cg: CGContext, rect: CGRect, color: UIColor) {
        cg.setFillColor(color.cgColor)
        cg.fill(rect)
    }

    private func fillRoundedRect(in cg: CGContext, rect: CGRect, radius: CGFloat, color: UIColor) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        cg.setFillColor(color.cgColor)
        cg.addPath(path.cgPath)
        cg.fillPath()
    }

    private func fillOval(in cg: CGContext, rect: CGRect, color: UIColor) {
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: rect)
    }

    private func fillCircle(in cg: CGContext, center: CGPoint, radius: CGFloat, color: UIColor) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: rect)
    }

    private func strokeCircle(in cg: CGContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, color: UIColor) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(lineWidth)
        cg.strokeEllipse(in: rect)
    }

    private func fillTriangle(in cg: CGContext, top: CGPoint, left: CGPoint, right: CGPoint, color: UIColor) {
        cg.beginPath()
        cg.move(to: top)
        cg.addLine(to: left)
        cg.addLine(to: right)
        cg.closePath()
        cg.setFillColor(color.cgColor)
        cg.fillPath()
    }

    private func fillTrapezoid(in cg: CGContext, topCenter: CGPoint, topWidth: CGFloat, bottomCenter: CGPoint, bottomWidth: CGFloat, color: UIColor) {
        cg.beginPath()
        cg.move(to: CGPoint(x: topCenter.x - topWidth / 2, y: topCenter.y))
        cg.addLine(to: CGPoint(x: topCenter.x + topWidth / 2, y: topCenter.y))
        cg.addLine(to: CGPoint(x: bottomCenter.x + bottomWidth / 2, y: bottomCenter.y))
        cg.addLine(to: CGPoint(x: bottomCenter.x - bottomWidth / 2, y: bottomCenter.y))
        cg.closePath()
        cg.setFillColor(color.cgColor)
        cg.fillPath()
    }

    private func fillArch(in cg: CGContext, rect: CGRect, color: UIColor) {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: rect.width / 2, height: rect.width / 2)
        )
        cg.setFillColor(color.cgColor)
        cg.addPath(path.cgPath)
        cg.fillPath()
    }

    private func drawCrown(in cg: CGContext, rect: CGRect, color: UIColor) {
        cg.beginPath()
        cg.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        cg.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2))
        cg.addLine(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.55))
        cg.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        cg.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.55))
        cg.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.2))
        cg.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        cg.closePath()
        cg.setFillColor(color.cgColor)
        cg.fillPath()
    }

    private func drawFlower(in cg: CGContext, center: CGPoint, radius: CGFloat, petalColor: UIColor, coreColor: UIColor) {
        for i in 0..<6 {
            let angle = (Double(i) / 6.0) * Double.pi * 2.0
            let px = center.x + CGFloat(cos(angle)) * radius * 0.55
            let py = center.y + CGFloat(sin(angle)) * radius * 0.55
            fillCircle(in: cg, center: CGPoint(x: px, y: py), radius: radius * 0.42, color: petalColor)
        }
        fillCircle(in: cg, center: center, radius: radius * 0.35, color: coreColor)
    }

    private func drawButterfly(in cg: CGContext, center: CGPoint, scale: CGFloat, primary: UIColor) {
        fillOval(in: cg, rect: CGRect(x: center.x - scale, y: center.y - scale * 0.7, width: scale * 0.9, height: scale * 0.8), color: primary)
        fillOval(in: cg, rect: CGRect(x: center.x + scale * 0.1, y: center.y - scale * 0.7, width: scale * 0.9, height: scale * 0.8), color: primary)
        fillOval(in: cg, rect: CGRect(x: center.x - scale * 0.8, y: center.y, width: scale * 0.7, height: scale * 0.6), color: primary)
        fillOval(in: cg, rect: CGRect(x: center.x + scale * 0.1, y: center.y, width: scale * 0.7, height: scale * 0.6), color: primary)
    }

    private func drawWavingFlag(in cg: CGContext, poleTop: CGPoint, poleBase: CGPoint, length: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(2.0)
        cg.move(to: poleBase)
        cg.addLine(to: poleTop)
        cg.strokePath()
        fillTriangle(
            in: cg,
            top: poleTop,
            left: CGPoint(x: poleTop.x - length, y: poleTop.y + 5),
            right: CGPoint(x: poleTop.x, y: poleTop.y + 10),
            color: color
        )
    }

    private func drawPrincessEyesAndSmile(in cg: CGContext, faceRect: CGRect, eyeColor: UIColor) {
        let leftEye = CGPoint(x: faceRect.minX + faceRect.width * 0.32, y: faceRect.minY + faceRect.height * 0.44)
        let rightEye = CGPoint(x: faceRect.minX + faceRect.width * 0.68, y: faceRect.minY + faceRect.height * 0.44)
        let eyeR = faceRect.width * 0.11

        for eye in [leftEye, rightEye] {
            fillCircle(in: cg, center: eye, radius: eyeR, color: .white)
            fillCircle(in: cg, center: eye, radius: eyeR * 0.65, color: eyeColor)
            fillCircle(in: cg, center: eye, radius: eyeR * 0.30, color: .black)
        }

        cg.beginPath()
        cg.move(to: CGPoint(x: faceRect.minX + faceRect.width * 0.32, y: faceRect.minY + faceRect.height * 0.72))
        cg.addQuadCurve(
            to: CGPoint(x: faceRect.minX + faceRect.width * 0.68, y: faceRect.minY + faceRect.height * 0.72),
            control: CGPoint(x: faceRect.midX, y: faceRect.minY + faceRect.height * 0.88)
        )
        cg.setStrokeColor(ThemeColors.uiColor(226, 48, 128).cgColor)
        cg.setLineWidth(3.0)
        cg.strokePath()
    }

    private func drawArm(in cg: CGContext, from start: CGPoint, to end: CGPoint, thickness: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(thickness)
        cg.setLineCap(.round)
        cg.move(to: start)
        cg.addLine(to: end)
        cg.strokePath()
    }

    private func drawLegWithShoe(in cg: CGContext, top: CGPoint, bottom: CGPoint, legColor: UIColor, shoeColor: UIColor) {
        drawArm(in: cg, from: top, to: bottom, thickness: 11.0, color: legColor)
        fillOval(in: cg, rect: CGRect(x: bottom.x - 9, y: bottom.y - 6, width: 18, height: 14), color: shoeColor)
    }
}
