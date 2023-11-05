//
//  AudioEngine.swift
//  YaCup
//
//  Created by igor.sorokin on 03.11.2023.
//

import Foundation
import AVFoundation
import Accelerate

final class AudioEngine {

    private final class Playable {
        let node: AudioRepeatablePlayerNode
        var volume: Float
        var muted: Bool

        init(node: AudioRepeatablePlayerNode, volume: Float, muted: Bool) {
            self.node = node
            self.volume = volume
            self.muted = muted
        }
    }

    var onLevelMeters: ((Float) -> Void)?

    private let engine = AVAudioEngine()
    private var playables: [Sample: Playable] = [:]
    private var currentTrackFile: AVAudioFile?
    private let filePathFactory = FilePathFactory()

    func prepare(sample: Sample, volume: Float, speed: Float, muted: Bool = false) {
        cleanup()
        prepareSingle(sample: sample, volume: volume, speed: speed, muted: muted)
    }

    func prepare(layers: [Layer]) {
        cleanup()
        layers.forEach {
            prepareSingle(sample: $0.sample, volume: $0.volume, speed: $0.speed, muted: $0.muted)
        }
    }

    func play() {
        guard !playables.isEmpty else {
            return
        }

        engine.prepare()
        try? engine.start()

        playables.values.forEach {
            $0.node.scheduleReplayFile()
            $0.node.play()
        }
    }

    func stop() {
        playables.values.forEach { $0.node.stop() }
        engine.stop()
    }

    func updateAll(volume: Float, speed: Float) {
        playables.keys.forEach {
            update(volume: volume, speed: speed, for: $0)
        }
    }

    func update(volume: Float, speed: Float, for sample: Sample) {
        guard let playable = playables[sample] else {
            return
        }

        playable.node.speed = speed
        playable.volume = volume

        if !playable.muted {
            playable.node.volume = volume
        }
    }

    func update(muted: Bool, for sample: Sample) {
        guard let playable = playables[sample] else {
            return
        }

        playable.muted = muted
        playable.node.volume = muted ? 0 : playable.volume
    }

    func startTrackRecording() {
        let url = filePathFactory.getFileURL()
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let file = try? AVAudioFile(forWriting: url, settings: format.settings)
        self.currentTrackFile = file

        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            try? file?.write(from: buffer)

            guard let channelData = buffer.floatChannelData else {
                return
            }

            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{ channelDataValue[$0] }
            let rms = sqrt(channelDataValueArray.map{$0 * $0}.reduce(0, +) / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)

            DispatchQueue.main.async {
                self?.onLevelMeters?(avgPower)
            }
        }
    }

    func stopTrackRecording() -> URL? {
        engine.mainMixerNode.removeTap(onBus: 0)
        let track = currentTrackFile
        self.currentTrackFile = nil
        return track?.url
    }

    private func prepareSingle(sample: Sample, volume: Float, speed: Float, muted: Bool) {
        guard let file = try? AVAudioFile(forReading: sample.url) else {
            return
        }

        let node = AudioRepeatablePlayerNode(speed: speed, file: file, time: nil)
        node.volume = muted ? 0 : volume

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)

        playables[sample] = Playable(node: node,
                                     volume: volume,
                                     muted: muted)
    }

    private func cleanup() {
        playables.values.forEach {
            engine.disconnectNodeInput($0.node)
        }

        let nodes = playables.values.map { $0.node }
        DispatchQueue.global().async { // avoid ui freezing
            nodes.forEach {
                self.engine.detach($0)
            }
        }

        playables.removeAll()
        currentTrackFile = nil
    }


}

