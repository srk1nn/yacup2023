//
//  VoiceRecorder.swift
//  YaCup
//
//  Created by igor.sorokin on 03.11.2023.
//

import Foundation
import AVFoundation

final class VoiceRecorder {
    private var recorder: AVAudioRecorder?
    private var currentFileURL: URL?
    private let filePathFactory = FilePathFactory()

    func prepareForRecording() {
        let fileURL = filePathFactory.getFileURL()
        self.currentFileURL = fileURL

        let settings: [String: Any] = [
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.prepareToRecord()
    }

    func start() {
        recorder?.record()
    }

    func finish() -> URL? {
        recorder?.stop()
        recorder = nil

        let url = currentFileURL
        currentFileURL = nil
        return url
    }
}
