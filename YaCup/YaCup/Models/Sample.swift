//
//  Sample.swift
//  YaCup
//
//  Created by igor.sorokin on 02.11.2023.
//

import Foundation

struct Sample: Hashable {
    let name: String
    let url: URL

    static var guitarSamples: [Sample] {
        [("Гитара 1", "useful guitar chords_60bpm"),
         ("Гитара 2", "Pack#1_ElectricGuitar_Mood 2_Ab Minor_75BPM"),
         ("Гитара 3", "Pack#1_ElectricGuitar_Mood 2_Em7_85BPM")]
            .map {
                Sample(name: $0.0, url: Bundle.main.url(forResource: $0.1, withExtension: "wav")!)
            }
    }

    static var brassSamples: [Sample] {
        [("Духовые 1", "Cymatics - Uzi Creep Melody Loop - 140 BPM F Min"),
         ("Духовые 2", "Cymatics - Uzi Ethereal Melody Loop - 140 BPM D Min"),
         ("Духовые 3", "Cymatics - Uzi Win Melody Loop - 120 BPM B Maj")]
            .map {
                Sample(name: $0.0, url: Bundle.main.url(forResource: $0.1, withExtension: "wav")!)
            }
    }

    static var drumSamples: [Sample] {
        [("Ударные 1", "Cymatics - Uzi Cash Full Drum Loop - 140 BPM"),
         ("Ударные 2", "Cymatics - Uzi Phase Top Drum Loop - 130 BPM"),
         ("Ударные 3", "Cymatics - Uzi Hihat Loop 3 - 150 BPM")]
            .map {
                Sample(name: $0.0, url: Bundle.main.url(forResource: $0.1, withExtension: "wav")!)
            }
    }
}
