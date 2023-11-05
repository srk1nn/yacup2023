//
//  Layer.swift
//  YaCup
//
//  Created by igor.sorokin on 02.11.2023.
//

import Foundation

final class Layer {
    let id: UUID = .init()
    let sample: Sample
    var volume: Float
    var speed: Float
    var muted: Bool = false
    var active: Bool = false

    init(sample: Sample, volume: Float, speed: Float) {
        self.sample = sample
        self.volume = volume
        self.speed = speed
    }
}
