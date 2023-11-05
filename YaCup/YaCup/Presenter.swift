//
//  Presenter.swift
//  YaCup
//
//  Created by igor.sorokin on 02.11.2023.
//

import Foundation
import AVFoundation

final class Presenter {

    struct State {
        let guitarSamples: [Sample] = Sample.guitarSamples
        let drumSamples: [Sample] = Sample.drumSamples
        let brassSamples: [Sample] = Sample.brassSamples
        var layers: [Layer]
        var currentLayer: Layer?

        var isCompositionRecording: Bool = false
        var isVoiceRecording: Bool = false
        var isPlayingComposition: Bool = false
    }

    private var state = State(layers: [], currentLayer: nil)

    private unowned var view: ViewController!
    private let engine = AudioEngine()
    private let recorder = VoiceRecorder()
    private let audioSession: AVAudioSession = .sharedInstance()
    private var voiceCounter = 0



    init(view: ViewController) {
        self.view = view

        try? audioSession.setCategory(.playback)
        try? audioSession.setActive(true)
    }

    func didLoadView() {
        engine.onLevelMeters = { [weak self] level in
            self?.view.update(level: level)
        }

        view.update(state: state)
    }

    func playSample(_ sample: Sample, volume: Float, speed: Float) {
        stopAllRecordings()

        resetState()
        view.update(state: state)

//        try? audioSession.setActive(true)

        engine.stop()
        engine.prepare(sample: sample, volume: volume, speed: speed)
        engine.play()
    }

    func stopPlaying() {
        engine.stop()
        stopAllRecordings()
    }

    func selectSample(_ sample: Sample, volume: Float, speed: Float) {
        resetState()

        let layer = Layer(sample: sample, volume: volume, speed: speed)
        layer.active = true
        state.layers.append(layer)
        state.currentLayer = layer

        view.update(state: state)
    }

    func update(volume: Float, speed: Float) {
        guard let currentLayer = state.currentLayer else {
            return
        }

        engine.update(volume: volume, speed: speed, for: currentLayer.sample)
        state.currentLayer?.volume = volume
        state.currentLayer?.speed = speed
    }

    func remove(layer: Layer) {
        let shouldStopEngine = state.isPlayingComposition || layer.active

        if shouldStopEngine {
            engine.stop()
        }

        if state.isCompositionRecording {
            stopTrackRecording()
        }

        if layer.active {
            state.currentLayer = nil
        }

        state.isPlayingComposition = false
        state.layers.removeAll(where: { $0.id == layer.id })
        view.update(state: state)
    }

    func update(muted: Bool, for layer: Layer) {
        guard let layer = state.layers.first(where: { $0.id == layer.id }) else {
            return
        }

        if state.isPlayingComposition {
            handlePlayComposition()
        }

        if state.isCompositionRecording {
            stopTrackRecording()
        }

        layer.muted = muted
        view.update(state: state)

        engine.update(muted: muted, for: layer.sample)
    }

    func updatePlaying(_ isPlaying: Bool, for layer: Layer) {
        stopAllRecordings()

        guard let layer = state.layers.first(where: { $0.id == layer.id }) else {
            return
        }

        engine.stop()

        resetState()

        if isPlaying {
            layer.active = true
            state.currentLayer = layer
        }

        view.update(state: state)

        if isPlaying {
            engine.prepare(sample: layer.sample, volume: layer.volume, speed: layer.speed, muted: layer.muted)
            engine.play()
        }
    }

    func handleVoiceRecoding() {
        if state.isCompositionRecording {
            stopTrackRecording()
        }

        engine.stop()

        let shouldRecord = !state.isVoiceRecording

        if shouldRecord {
            startVoiceRecoding()
        } else {
            stopVoiceRecording()
        }
    }

    private func startVoiceRecoding() {
        try? audioSession.setCategory(.record)

        audioSession.requestRecordPermission() { allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.resetState()
                    self.state.isVoiceRecording = true
                    self.view.update(state: self.state)

                    self.recorder.prepareForRecording()
                    self.recorder.start()
                } else {
                    // TODO: show error
                }
            }
        }
    }

    private func stopVoiceRecording() {
        let resultURL = recorder.finish()

        try? audioSession.setCategory(.playback)

        guard let resultURL else {
            return
        }

        resetState()

        voiceCounter += 1
        let layer = Layer(sample: Sample(name: "Вокал \(voiceCounter)", url: resultURL),
                          volume: 1,
                          speed: 1)

        state.currentLayer = layer
        state.layers.append(layer)
        view.update(state: state)
    }

    func handlePlayComposition() {
        stopAllRecordings()

        let shouldPlay = !state.isPlayingComposition

        resetState()
        state.isPlayingComposition = shouldPlay

        view.update(state: state)

        engine.stop()

        if shouldPlay {
            engine.prepare(layers: state.layers)
            engine.play()
        }
    }

    func handleTrackRecording() {
        if state.isVoiceRecording {
            stopVoiceRecording()
        }

        let shouldRecord = !state.isCompositionRecording

        if shouldRecord {
            startTrackRecording()
        } else {
            stopTrackRecording()
        }
    }

    private func startTrackRecording() {
        engine.stop()

        resetState()
        state.isCompositionRecording = true
        view.update(state: state)

        try? audioSession.setCategory(.playAndRecord)
        try? audioSession.setActive(true)

        engine.prepare(layers: state.layers)
        engine.startTrackRecording()
        engine.play()
    }

    private func stopTrackRecording() {
        engine.stop()

        resetState()
        view.update(state: state)

        let result = engine.stopTrackRecording()

        try? audioSession.setCategory(.playback)

        if let result {
            view.share(trackURL: result)
        }
    }

    private func stopAllRecordings() {
        if state.isVoiceRecording {
            stopVoiceRecording()
        }

        if state.isCompositionRecording {
            stopTrackRecording()
        }
    }

    private func resetState() {
        state.layers.forEach { $0.active = false }
        state.currentLayer = nil
        state.isVoiceRecording = false
        state.isPlayingComposition = false
        state.isCompositionRecording = false
    }
}
