//
//  AudioRepeatablePlayerNode.swift
//  YaCup
//
//  Created by igor.sorokin on 04.11.2023.
//

import Foundation
import Combine
import AVFoundation

final class AudioRepeatablePlayerNode: AVAudioPlayerNode {

    enum Replay {
        case immediately
        case timer(ReplayTimer)
        case never

        init(milliseconds: Int) {
            let minDeviation = (0...100)
            let maxDeviation = (3900...4000)

            if minDeviation.contains(milliseconds) {
                self = .immediately
            } else if maxDeviation.contains(milliseconds) {
                self = .never
            } else {
                self = .timer(ReplayTimer(milliseconds: milliseconds))
            }
        }
    }

    private var replay: Replay!
    private let speedSubject: PassthroughSubject<Float, Never> = .init()
    private var bag = Set<AnyCancellable>()
    private var isNowPlaying: Bool = false
    private var explicitlyStopped: Bool = false

    private let file: AVAudioFile
    private let time: AVAudioTime?

    var speed: Float {
        didSet {
            speedSubject.send(speed)
        }
    }

    init(speed: Float, file: AVAudioFile, time: AVAudioTime?) {
        self.speed = speed
        self.file = file
        self.time = time
        super.init()
        self.replay = Replay(milliseconds: normalizeSpeed(speed))

        speedSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }

                print("Speed \(self.normalizeSpeed($0))")

                // cancel previous timer
                if case .timer(let timer) = self.replay {
                    timer.cancel()
                }

                self.replay = Replay(milliseconds: self.normalizeSpeed($0))

                if !isNowPlaying {

                    switch self.replay {
                    case .immediately, .timer:
                        // start playing if not playing
                        self.scheduleReplayFile()
                        self.play()
                    default:
                        break
                    }

                }
            }
            .store(in: &bag)
    }

    /// speed – delay for replay in milliseconds. From 0 to 3000, but
    /// 0 – play immediately after the end
    /// 4000 – never repeat
    private func normalizeSpeed(_ speed: Float) -> Int {
        Int(speed * 4 * 1000)
    }

    func scheduleReplayFile() {
        scheduleFile(file, at: time, completionHandler: { [weak self] in
            DispatchQueue.main.async {
                guard let self, !self.explicitlyStopped else {
                    return
                }

                self.isNowPlaying = false

                switch self.replay {
                case .immediately:
                    self.scheduleReplayFile()
                    self.play()
                case .timer(let timer):
                    timer.start(onFire: { [weak self] in
                        self?.scheduleReplayFile()
                        self?.play()
                    })
                default:
                    break
                }
            }
        })
    }

    override func play() {
        super.play()
        isNowPlaying = true
    }

    override func stop() {
        super.stop()

        explicitlyStopped = true
        isNowPlaying = false

        switch replay {
        case .timer(let timer):
            timer.cancel()
        default:
            break
        }
    }

}
