//
//  SelectorView.swift
//  YaCup
//
//  Created by igor.sorokin on 01.11.2023.
//

import UIKit

protocol SelectorViewDelegate: AnyObject {
    func selectorViewDidChanged(speed: Float, volume: Float)
}

final class SelectorView: UIView {
    weak var delegate: SelectorViewDelegate?

    var volume: Float {
        get {
            volume(from: volumeViewRealOffset())
        }
        set {
            volumeView.frame.origin.y = volumeOriginY(from: newValue)
        }
    }

    var speed: Float {
        get {
            speed(from: speedViewRealOffset())
        }
        set {
            speedView.frame.origin.x = speedOriginX(from: newValue)
        }
    }

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    private var isFirstLayout = true
    private let speedView = SelectorSliderView()
    private let volumeView = SelectorSliderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPanned(_:)))
        addGestureRecognizer(pan)

        gradientLayer.colors = [UIColor.black.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        speedView.title = "скорость"
        volumeView.title = "громкость"
        volumeView.setAnchorPoint(.zero)

        addSubview(speedView)
        addSubview(volumeView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstLayout {
            setupBottomLinePatterns()
            setupLeftLinePatterns()

            // bring to from after adding lines
            bringSubviewToFront(speedView)
            bringSubviewToFront(volumeView)

            speedView.frame = .init(
                x: Constants.speedLineLeftOffset,
                y: bounds.height - Constants.sliderHeight,
                width: Constants.sliderWidth,
                height: Constants.sliderHeight)

            volumeView.frame = .init(
                x: 0,
                y: bounds.width - Constants.volumeLineBottomOffset,
                width: Constants.sliderWidth,
                height: Constants.sliderHeight)

            volumeView.transform = CGAffineTransform(rotationAngle: -.pi / 2)

            isFirstLayout = false
        }
    }

    private func setupBottomLinePatterns() {
        let leftBoundary = Constants.speedLineLeftOffset
        var offset: CGFloat = bounds.width - Constants.speedSepWidth
        var factor: CGFloat = 3

        while offset > leftBoundary {
            let line = CALayer()
            line.backgroundColor = UIColor.white.cgColor
            line.frame = .init(
                x: offset,
                y: bounds.height - Constants.speedSepHeight,
                width: Constants.speedSepWidth,
                height: Constants.speedSepHeight)
            layer.addSublayer(line)
            offset -= factor
            factor += 0.3
        }
    }

    private func setupLeftLinePatterns() {
        let sections = 6
        let availableHeight = bounds.height - Constants.volumeLineBottomOffset
        let sectionSpacing = (availableHeight - CGFloat(sections)) / CGFloat(sections - 1)

        let subsections = 4
        let subsectionSpacing = (sectionSpacing - CGFloat(subsections)) / CGFloat(subsections + 1)

        var offset: CGFloat = 1
        for section in (0..<sections) {
            let line = CALayer()
            line.backgroundColor = UIColor.white.cgColor
            line.frame = .init(x: 0, y: offset, width: Constants.volumeSecWidth, height: Constants.volumeSecHeight)
            layer.addSublayer(line)

            guard section != sections - 1 else {
                break
            }

            var subsectionOffset = offset + subsectionSpacing
            for _ in (0..<subsections) {
                let line = CALayer()
                line.backgroundColor = UIColor.white.cgColor
                line.frame = .init(x: 0, y: subsectionOffset, width: Constants.volumeSubSecWidth, height: Constants.volumeSubSecHeight)
                layer.addSublayer(line)
                subsectionOffset += subsectionSpacing
            }

            offset += sectionSpacing
        }
    }

    @objc
    private func didPanned(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)

        guard sender.state == .changed, bounds.contains(location) else {
            return
        }

        let speed = speed(from: location.x)
        let volume = volume(from: location.y)

        let speedOriginX = speedOriginX(from: speed)
        let volumeOriginY = volumeOriginY(from: volume)

        speedView.frame.origin.x = speedOriginX
        volumeView.frame.origin.y = volumeOriginY
        delegate?.selectorViewDidChanged(speed: speed, volume: volume)
    }

    private func volume(from offset: CGFloat) -> Float {
        1 - Float(offset / bounds.height)
    }

    private func speed(from offset: CGFloat) -> Float {
        Float(offset / bounds.width)
    }

    private func speedOriginX(from speed: Float) -> CGFloat {
        let offset = CGFloat(speed) * bounds.width
        let leftBound = Constants.speedLineLeftOffset
        let rightBound = bounds.width - Constants.sliderWidth
        let speedRatio = (rightBound - leftBound) / bounds.width
        let speedOriginX = (offset * speedRatio) + leftBound
        return speedOriginX
    }

    private func volumeOriginY(from volume: Float) -> CGFloat {
        let offset = (1 - CGFloat(volume)) * bounds.height
        let topBound = Constants.sliderWidth
        let bottomBound = bounds.height - Constants.volumeLineBottomOffset
        let volumeRatio = (bottomBound - topBound) / bounds.height
        let volumeOriginY = (offset * volumeRatio) + topBound
        return volumeOriginY
    }

    private func speedViewRealOffset() -> CGFloat {
        let originX = speedView.frame.origin.x
        let leftBound = Constants.speedLineLeftOffset
        let rightBound = bounds.width - Constants.sliderWidth
        let speedRatio = bounds.width / (rightBound - leftBound)
        let offset = (originX - leftBound) * speedRatio
        return offset
    }

    private func volumeViewRealOffset() -> CGFloat {
        let originY = volumeView.frame.origin.y
        let topBound = Constants.sliderWidth
        let bottomBound = bounds.height - Constants.volumeLineBottomOffset
        let volumeRatio = bounds.height / (bottomBound - topBound)
        let offset = originY * volumeRatio
        return offset
    }

    private enum Constants {
        static let sliderHeight: CGFloat = 15
        static let sliderWidth: CGFloat = 60
        static let speedLineLeftOffset: CGFloat = 15
        static let volumeLineBottomOffset: CGFloat = 15
        static let speedSepWidth: CGFloat = 1
        static let speedSepHeight: CGFloat = 15
        static let volumeSecWidth: CGFloat = 15
        static let volumeSecHeight: CGFloat = 1
        static let volumeSubSecWidth: CGFloat = 7
        static let volumeSubSecHeight: CGFloat = 1
    }
}
