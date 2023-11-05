//
//  WaveView.swift
//  YaCup
//
//  Created by igor.sorokin on 04.11.2023.
//

import UIKit

final class WaveView: UIView {
    private let imageView = UIImageView()
    private let replicator = CAReplicatorLayer()
    private let dot = CALayer()
    private var lastTransformScale: CGFloat = 0
    private var isFirstLayout = true

    private let dotLength: CGFloat = 3.0
    private let dotOffset: CGFloat = 5.0

    var level: Float = 0 {
        didSet {
            updateLevel()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isFirstLayout else {
            return
        }

        isFirstLayout = false

        replicator.frame = bounds
        layer.addSublayer(replicator)

        dot.frame = CGRect(
            x: replicator.frame.size.width - dotLength,
            y: replicator.position.y,
            width: dotLength,
            height: dotLength)

        dot.backgroundColor = UIColor.white.cgColor
        dot.cornerRadius = 1

        replicator.addSublayer(dot)
        replicator.instanceCount = Int(frame.size.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0, 0)
        replicator.instanceDelay = 0.02
    }

    func update(recording: Bool) {
        imageView.isHidden = recording
        replicator.isHidden = !recording

        if !recording {
            dot.removeAllAnimations()
        }
    }

    private func setupUI() {
        backgroundColor = .black

        imageView.image = .init(named: "wave")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.4

        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func updateLevel() {
        let scaleFactor = max(0.2, CGFloat(level) + 40) / 2
        let scale = CABasicAnimation(keyPath: "transform.scale.y")
        scale.fromValue = lastTransformScale
        scale.toValue = scaleFactor
        scale.duration = 0.1
        scale.isRemovedOnCompletion = false
        scale.fillMode = .forwards
        dot.add(scale, forKey: nil)

        lastTransformScale = scaleFactor
    }
}
