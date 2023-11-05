//
//  MainView.swift
//  YaCup
//
//  Created by igor.sorokin on 01.11.2023.
//

import UIKit

final class MainView: UIView {
    let guitarView = InstrumentView()
    let drumView = InstrumentView()
    let brassView = InstrumentView()
    let selectorView = SelectorView()

    let bottomStack = UIStackView()
    let layersButton = LayersButton()
    let voiceButton = UIButton()
    let recordButton = UIButton()
    let playButton = UIButton()

    let waveView = WaveView()

    let tableView = UITableView()
    var tableViewHeightConstraint: NSLayoutConstraint?

    private var isFirstLayout = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        guitarView.image = UIImage(named: "guitar")
        drumView.image = UIImage(named: "drum")
        brassView.image = UIImage(named: "brass")
        
        guitarView.title = "гитара"
        drumView.title = "ударные"
        brassView.title = "духовые"

        voiceButton.layer.cornerRadius = 4
        voiceButton.backgroundColor = .white
        voiceButton.setImage(.init(named: "micro"), for: .normal)
        voiceButton.setImage(.init(named: "activemic"), for: .selected)

        recordButton.layer.cornerRadius = 4
        recordButton.backgroundColor = .white
        recordButton.setImage(.init(named: "record"), for: .normal)
        recordButton.setImage(.init(named: "activerec"), for: .selected)

        playButton.layer.cornerRadius = 4
        playButton.backgroundColor = .white
        playButton.setImage(.init(named: "play"), for: .normal)
        playButton.setImage(.init(named: "stop"), for: .selected)

        bottomStack.spacing = 5

        tableView.register(.init(nibName: "LayerCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.rowHeight = 55
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        let spacer = UIView()
        spacer.backgroundColor = .clear

        addSubview(selectorView)
        addSubview(guitarView)
        addSubview(drumView)
        addSubview(brassView)
        addSubview(bottomStack)
        addSubview(waveView)
        addSubview(tableView)

        bottomStack.addArrangedSubview(layersButton)
        bottomStack.addArrangedSubview(spacer)
        bottomStack.addArrangedSubview(voiceButton)
        bottomStack.addArrangedSubview(recordButton)
        bottomStack.addArrangedSubview(playButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstLayout {
            setupLayout()
            isFirstLayout = false
        }
    }

    private func setupLayout() {
        let interButtonSpacing: CGFloat = 55
        let edgeButtonSpacing: CGFloat = 15
        let availableWidth = bounds.width - (2 * interButtonSpacing) - (2 * edgeButtonSpacing)
        let buttonSide = availableWidth / 3

        let selectorEdgeSpacing: CGFloat = 15
        let selectorTopSpacing: CGFloat = 58

        let bottomSpacing: CGFloat = 15

        let waveSpacing: CGFloat = 10

        guitarView.translatesAutoresizingMaskIntoConstraints = false
        guitarView.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeButtonSpacing).isActive = true
        guitarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeButtonSpacing).isActive = true
        guitarView.widthAnchor.constraint(equalToConstant: buttonSide).isActive = true

        drumView.translatesAutoresizingMaskIntoConstraints = false
        drumView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        drumView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeButtonSpacing).isActive = true
        drumView.widthAnchor.constraint(equalToConstant: buttonSide).isActive = true

        brassView.translatesAutoresizingMaskIntoConstraints = false
        brassView.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeButtonSpacing).isActive = true
        brassView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeButtonSpacing).isActive = true
        brassView.widthAnchor.constraint(equalToConstant: buttonSide).isActive = true

        selectorView.translatesAutoresizingMaskIntoConstraints = false
        selectorView.leftAnchor.constraint(equalTo: leftAnchor, constant: selectorEdgeSpacing).isActive = true
        selectorView.rightAnchor.constraint(equalTo: rightAnchor, constant: -selectorEdgeSpacing).isActive = true
        selectorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeButtonSpacing + buttonSide + selectorTopSpacing).isActive = true
        selectorView.bottomAnchor.constraint(equalTo: waveView.topAnchor, constant: -13).isActive = true

        layersButton.translatesAutoresizingMaskIntoConstraints = false
        layersButton.widthAnchor.constraint(equalToConstant: 74).isActive = true
        layersButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        voiceButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpacing).isActive = true
        bottomStack.leftAnchor.constraint(equalTo: leftAnchor, constant: bottomSpacing).isActive = true
        bottomStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -bottomSpacing).isActive = true

        waveView.translatesAutoresizingMaskIntoConstraints = false
        waveView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -waveSpacing).isActive = true
        waveView.leftAnchor.constraint(equalTo: leftAnchor, constant: bottomSpacing).isActive = true
        waveView.rightAnchor.constraint(equalTo: rightAnchor, constant: -bottomSpacing).isActive = true
        waveView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: waveView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor, constant: bottomSpacing).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -bottomSpacing).isActive = true
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }

}
