//
//  LayersButton.swift
//  YaCup
//
//  Created by igor.sorokin on 02.11.2023.
//

import UIKit

final class LayersButton: UIButton {

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .secondary : .white
            let name = isSelected ? "down" : "vector"
            setImage(.init(named: name), for: .normal)
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
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 30)
        imageEdgeInsets = .init(top: 0, left: 50, bottom: 0, right: 0)
        layer.cornerRadius = 4
        backgroundColor = .white
        setImage(.init(named: "vector"), for: .normal)
        setTitle("Слои", for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 12)
    }

}
