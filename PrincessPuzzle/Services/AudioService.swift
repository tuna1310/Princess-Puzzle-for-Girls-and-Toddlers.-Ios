import AVFoundation
import Foundation

/// Protocol for game sound effects and fairy-tale audio feedback.
public protocol AudioServiceProtocol: AnyObject {
    var isSoundEnabled: Bool { get set }
    func playWheelRotateTick()
    func playPiecePickup()
    func playPieceSnap()
    func playPieceDrop()
    func playBubblePop(pitchIndex: Int)
    func playVictoryFanfare()
}

/// Native `AVFoundation` audio engine that synthesizes multi-harmonic PCM WAV buffers in memory
/// so every puzzle interaction has responsive, cheerful sound effects with zero missing-asset risk.
public final class AudioService: AudioServiceProtocol {
    public static let shared = AudioService()

    public var isSoundEnabled: Bool = true

    private var activePlayers: [AVAudioPlayer] = []
    private var cachedClips: [String: Data] = [:]
    private let queue = DispatchQueue(label: "com.thasmobi.physicsPuzzle05.audioQueue")

    public init() {
        configureAudioSession()
        prewarmSynthesizedClips()
    }

    public func playWheelRotateTick() {
        playClip(named: "wheel_tick", volume: 0.42)
    }

    public func playPiecePickup() {
        playClip(named: "piece_pickup", volume: 0.55)
    }

    public func playPieceSnap() {
        playClip(named: "piece_snap", volume: 0.75)
    }

    public func playPieceDrop() {
        playClip(named: "piece_drop", volume: 0.45)
    }

    public func playBubblePop(pitchIndex: Int = 0) {
        let clamped = abs(pitchIndex) % 5
        playClip(named: "bubble_pop_\(clamped)", volume: 0.65)
    }

    public func playVictoryFanfare() {
        playClip(named: "victory_fanfare", volume: 0.82)
    }

    // MARK: - Audio Session & Playback

    private func configureAudioSession() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Safe fallback on CI headless simulator without audio hardware
        }
        #endif
    }

    private func playClip(named name: String, volume: Float) {
        guard isSoundEnabled else { return }
        queue.async { [weak self] in
            guard let self = self, let wavData = self.cachedClips[name] else { return }
            do {
                let player = try AVAudioPlayer(data: wavData)
                player.volume = volume
                player.prepareToPlay()
                player.play()
                self.activePlayers.removeAll { !$0.isPlaying }
                self.activePlayers.append(player)
            } catch {
                // Ignore playback errors on headless test runners
            }
        }
    }

    // MARK: - In-Memory WAV Synthesizer

    private func prewarmSynthesizedClips() {
        // 1. Wheel rotation soft wooden click/chime
        cachedClips["wheel_tick"] = Self.generateToneSequenceWAV(
            notes: [(frequency: 587.33, duration: 0.045)],
            amplitude: 0.32
        )

        // 2. Piece pickup rising pop (C5 -> G5)
        cachedClips["piece_pickup"] = Self.generateToneSequenceWAV(
            notes: [
                (frequency: 523.25, duration: 0.045),
                (frequency: 783.99, duration: 0.065)
            ],
            amplitude: 0.40
        )

        // 3. Piece snap into slot magical sparkle chime (C5 -> E5 -> G5 -> C6)
        cachedClips["piece_snap"] = Self.generateToneSequenceWAV(
            notes: [
                (frequency: 523.25, duration: 0.055),
                (frequency: 659.25, duration: 0.055),
                (frequency: 783.99, duration: 0.065),
                (frequency: 1046.50, duration: 0.16)
            ],
            amplitude: 0.48
        )

        // 4. Piece released outside target slot soft bounce (E4 -> C4)
        cachedClips["piece_drop"] = Self.generateToneSequenceWAV(
            notes: [
                (frequency: 329.63, duration: 0.055),
                (frequency: 261.63, duration: 0.085)
            ],
            amplitude: 0.35
        )

        // 5. Pentatonic bubble pop pitches
        let pentatonic: [Double] = [523.25, 587.33, 659.25, 783.99, 880.00]
        for (index, freq) in pentatonic.enumerated() {
            cachedClips["bubble_pop_\(index)"] = Self.generateToneSequenceWAV(
                notes: [
                    (frequency: freq, duration: 0.04),
                    (frequency: freq * 1.5, duration: 0.07)
                ],
                amplitude: 0.45
            )
        }

        // 6. Victory royal fanfare (C5 - E5 - G5 - C6 - G5 - C6)
        cachedClips["victory_fanfare"] = Self.generateToneSequenceWAV(
            notes: [
                (frequency: 523.25, duration: 0.11),
                (frequency: 659.25, duration: 0.11),
                (frequency: 783.99, duration: 0.11),
                (frequency: 1046.50, duration: 0.22),
                (frequency: 783.99, duration: 0.10),
                (frequency: 1046.50, duration: 0.34)
            ],
            amplitude: 0.52
        )
    }

    /// Generates a valid 16-bit mono 44.1 kHz PCM `.wav` file in memory from a sequence of notes.
    public static func generateToneSequenceWAV(
        notes: [(frequency: Double, duration: Double)],
        amplitude: Double = 0.4,
        sampleRate: Int = 44_100
    ) -> Data {
        var samples: [Int16] = []
        for note in notes {
            let count = max(1, Int(note.duration * Double(sampleRate)))
            for i in 0..<count {
                let t = Double(i) / Double(sampleRate)
                let progress = Double(i) / Double(count)
                // Smooth attack-decay envelope to eliminate clicks
                let attack = min(1.0, progress / 0.08)
                let decay = pow(1.0 - progress, 1.35)
                let envelope = attack * decay

                let fundamental = sin(2.0 * Double.pi * note.frequency * t)
                let overtone1 = 0.28 * sin(2.0 * Double.pi * (note.frequency * 2.0) * t)
                let overtone2 = 0.10 * sin(2.0 * Double.pi * (note.frequency * 3.0) * t)
                let raw = (fundamental + overtone1 + overtone2) / 1.38
                let value = max(-1.0, min(1.0, raw * amplitude * envelope))
                samples.append(Int16(value * Double(Int16.max)))
            }
        }

        let dataChunkSize = samples.count * MemoryLayout<Int16>.size
        let riffChunkSize = 36 + dataChunkSize

        var wav = Data(capacity: 44 + dataChunkSize)
        wav.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        wav.append(uint32LE: UInt32(riffChunkSize))
        wav.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        wav.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        wav.append(uint32LE: 16)                          // PCM chunk size
        wav.append(uint16LE: 1)                           // AudioFormat = 1 (PCM)
        wav.append(uint16LE: 1)                           // NumChannels = 1 (Mono)
        wav.append(uint32LE: UInt32(sampleRate))          // SampleRate
        wav.append(uint32LE: UInt32(sampleRate * 2))      // ByteRate
        wav.append(uint16LE: 2)                           // BlockAlign
        wav.append(uint16LE: 16)                          // BitsPerSample
        wav.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        wav.append(uint32LE: UInt32(dataChunkSize))

        for sample in samples {
            wav.append(int16LE: sample)
        }
        return wav
    }
}

private extension Data {
    mutating func append(uint16LE value: UInt16) {
        var le = value.littleEndian
        Swift.withUnsafeBytes(of: &le) { append(contentsOf: $0) }
    }

    mutating func append(uint32LE value: UInt32) {
        var le = value.littleEndian
        Swift.withUnsafeBytes(of: &le) { append(contentsOf: $0) }
    }

    mutating func append(int16LE value: Int16) {
        var le = value.littleEndian
        Swift.withUnsafeBytes(of: &le) { append(contentsOf: $0) }
    }
}
