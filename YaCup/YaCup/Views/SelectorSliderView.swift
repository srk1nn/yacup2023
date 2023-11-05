//
//  SelectorSliderView.swift
//  YaCup
//
//  Created by igor.sorokin on 01.11.2023.
//

import UIKit

final class SelectorSliderView: UIView {
    private let label = UILabel()

    var title: String? {
        didSet {
            label.text = title
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
        layer.cornerRadius = 4
        backgroundColor = .secondary

        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 11, weight: .regular)

        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.frame = bounds
    }
}
