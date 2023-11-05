//
//  ReplayTimer.swift
//  YaCup
//
//  Created by igor.sorokin on 03.11.2023.
//

import Foundation

final class ReplayTimer {
    private var timer: Timer?
    private var onFire: VoidClosure?
    private var milliseconds: Int

    init(milliseconds: Int) {
        self.milliseconds = milliseconds
    }

    func start(onFire: @escaping VoidClosure) {
        self.onFire = onFire
        let timer = Timer(timeInterval: Double(milliseconds) / 1000, 
                          repeats: false,
                          block: { [weak self] tmpTimer in
            onFire()
            self?.cancel()
        })

        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        onFire = nil
    }

}
