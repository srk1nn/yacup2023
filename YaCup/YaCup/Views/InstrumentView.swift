//
//  InstrumentView.swift
//  YaCup
//
//  Created by igor.sorokin on 01.11.2023.
//

import UIKit

protocol InstrumentViewDelegate: AnyObject {
    func instrumentViewChangeExpand(_ instrumentView: InstrumentView, isExpanded: Bool)
    func instrumentViewWillSelectSample(_ instrumentView: InstrumentView, sample: Sample)
    func instrumentViewDidSelectSample(_ instrumentView: InstrumentView, sample: Sample)
    func instrumentViewFailToSelect(_ instrumentView: InstrumentView)
}

final class InstrumentView: UIView {
    weak var delegate: InstrumentViewDelegate?

    private var isFirstLayout = true
    private var expanded = false
    private var currentSelectedSample: UILabel?

    private let imageView = UIImageView()
    private let label = UILabel()
    private let expandedStackView = UIStackView()
    private let containerStackView = UIStackView()

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var title: String? {
        didSet {
            label.text = title
        }
    }

    var samples: [Sample] = [] {
        didSet {
            updateSamples()
        }
    }

    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.3
            label.alpha = isEnabled ? 1 : 0.3
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

    private func setupUI() {
        backgroundColor = .white

        imageView.contentMode = .scaleAspectFill

        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)

        containerStackView.axis = .vertical
        containerStackView.spacing = 8

        expandedStackView.axis = .vertical
        expandedStackView.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapped))
        addGestureRecognizer(tap)

        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPressed))
        addGestureRecognizer(press)

        addSubview(label)
        addSubview(containerStackView)

        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(expandedStackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstLayout {
            setupLayout()
            layer.cornerRadius = bounds.width / 2

            isFirstLayout = false
        }
    }

    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor, constant: bounds.width + 8).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        heightAnchor.constraint(equalTo: containerStackView.heightAnchor).isActive = true
    }

    private func updateSamples() {
        expandedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        samples.forEach {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .black
            label.text = $0.name
            label.textAlignment = .center
            label.isHidden = true
            label.alpha = 0
            expandedStackView.addArrangedSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        let spacer = UIView()
        spacer.isHidden = true
        spacer.alpha = 0
        spacer.backgroundColor = .clear
        expandedStackView.addArrangedSubview(spacer)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        spacer.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }

    @objc
    private func didTapped(_ sender: UITapGestureRecognizer) {
        guard isEnabled else {
            return
        }

        guard let sample = samples.first else {
            return
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        delegate?.instrumentViewWillSelectSample(self, sample: sample)
        delegate?.instrumentViewDidSelectSample(self, sample: sample)

        UIView.animateKeyframes(withDuration: 0.3, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.transform = .identity
            }
        }
    }

    @objc
    private func didPressed(_ sender: UILongPressGestureRecognizer) {
        guard isEnabled else {
            return
        }

        func resetState() {
            currentSelectedSample = nil
            expandedStackView.arrangedSubviews.forEach { $0.backgroundColor = .clear }
            updateExpanded(false)
        }

        switch sender.state {
        case .began:
            updateExpanded(true)

        case .changed:
            let location = sender.location(in: expandedStackView)

            let hasSelected = expandedStackView.arrangedSubviews.contains(where: {
                $0 is UILabel && $0.frame.contains(location)
            })

            guard hasSelected else {
                break
            }

            for view in expandedStackView.arrangedSubviews {
                guard let sampleLabel = view as? UILabel else {
                    continue
                }

                let isSelected = sampleLabel.frame.contains(location)
                sampleLabel.setSelected(isSelected)

                if isSelected,
                   currentSelectedSample !== sampleLabel,
                   let text = sampleLabel.text,
                   let sample = samples.first(where: { $0.name == text }) {

                    currentSelectedSample = sampleLabel
                    delegate?.instrumentViewWillSelectSample(self, sample: sample)
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
            }
        case .ended:
            let selectedSample = currentSelectedSample

            resetState()

            if let text = selectedSample?.text, let sample = samples.first(where: { $0.name == text }) {
                delegate?.instrumentViewDidSelectSample(self, sample: sample)
            }

        case .cancelled, .failed:
            resetState()
            delegate?.instrumentViewFailToSelect(self)

        default:
            break
        }
    }

    private func updateExpanded(_ newExpanded: Bool) {

        delegate?.instrumentViewChangeExpand(self, isExpanded: newExpanded)

        UIView.animate(withDuration: 0.3, animations: {
            self.label.alpha = newExpanded ? 0 : 1
            self.backgroundColor = newExpanded ? .secondary : .white
            self.expandedStackView.subviews.forEach { $0.isHidden = !newExpanded }
            self.expandedStackView.subviews.forEach { $0.alpha = newExpanded ? 1 : 0 }
            self.expandedStackView.isHidden = !newExpanded
        }, completion: { _ in
            self.expanded = newExpanded
        })
    }
}

private extension UIView {

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .white : .clear

        if selected {
            let maskLayer = CAGradientLayer()
            maskLayer.frame = bounds
            maskLayer.shadowRadius = 4
            maskLayer.shadowPath = CGPath(rect: bounds.inset(by: .init(top: 4, left: -4, bottom: 4, right: -4)), transform: nil)
            maskLayer.shadowOpacity = 1
            maskLayer.shadowOffset = CGSize.zero
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }
    }

}
