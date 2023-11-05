//
//  ViewController.swift
//  YaCup
//
//  Created by igor.sorokin on 31.10.2023.
//

import UIKit

typealias VoidClosure = () -> Void

final class ViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private unowned var mainView: MainView!
    private unowned var guitarView: InstrumentView!
    private unowned var drumView: InstrumentView!
    private unowned var brassView: InstrumentView!
    private unowned var selectorView: SelectorView!
    private unowned var layersButton: LayersButton!
    private unowned var voiceButton: UIButton!
    private unowned var recordButton: UIButton!
    private unowned var playButton: UIButton!
    private unowned var tableView: UITableView!
    private unowned var waveView: WaveView!

    private var isTableViewExpanded: Bool = false
    private var layers: [Layer] = []

    private lazy var presenter = Presenter(view: self)

    override func loadView() {
        let mainView = MainView()
        view = mainView
        self.mainView = mainView
        guitarView = mainView.guitarView
        drumView = mainView.drumView
        brassView = mainView.brassView
        selectorView = mainView.selectorView
        layersButton = mainView.layersButton
        voiceButton = mainView.voiceButton
        recordButton = mainView.recordButton
        playButton = mainView.playButton
        tableView = mainView.tableView
        waveView = mainView.waveView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        presenter.didLoadView()
    }

    private func setup() {
        guitarView.delegate = self
        drumView.delegate = self
        brassView.delegate = self
        selectorView.delegate = self
        tableView.dataSource = self

        layersButton.addTarget(self, action: #selector(didTapLayer), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(didTapVoice), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
    }

    func update(state: Presenter.State) {
        // assign once
        if guitarView.samples.isEmpty {
            guitarView.samples = state.guitarSamples
            drumView.samples = state.drumSamples
            brassView.samples = state.brassSamples
        }

        if let currentLayer = state.currentLayer {
            selectorView.volume = currentLayer.volume
            selectorView.speed = currentLayer.speed
        }

        layers = state.layers
        tableView.reloadData()

        playButton.isSelected = state.isPlayingComposition
        voiceButton.isSelected = state.isVoiceRecording
        recordButton.isSelected = state.isCompositionRecording

        waveView.update(recording: state.isCompositionRecording)

        if isTableViewExpanded {
            tableView(expanded: true)
        }
    }

    func update(level: Float) {
        waveView.level = level
    }

    func share(trackURL: URL) {
        let controller = UIActivityViewController(activityItems: [trackURL], applicationActivities: nil)
        present(controller, animated: true)
    }

    @objc
    private func didTapLayer() {
        layersButton.isSelected.toggle()
        tableView(expanded: layersButton.isSelected)
    }

    @objc
    private func didTapVoice() {
        presenter.handleVoiceRecoding()
    }

    @objc
    private func didTapPlay() {
        presenter.handlePlayComposition()
    }

    @objc
    private func didTapRecord() {
        presenter.handleTrackRecording()
    }

    private func tableView(expanded: Bool) {
        isTableViewExpanded = expanded

        let cellHeight: CGFloat = 55
        let layersHeight = cellHeight * CGFloat(layers.count)
        let maxTableHeight = 5.5 * cellHeight
        let tableHeight = expanded ? min(maxTableHeight, layersHeight) : 0

        mainView.tableViewHeightConstraint?.constant = tableHeight

        UIView.animate(withDuration: 0.3) {
            self.waveView.alpha = (tableHeight == 0) ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }

}

extension ViewController: InstrumentViewDelegate {
    func instrumentViewDidSelectSample(_ instrumentView: InstrumentView, sample: Sample) {
        presenter.selectSample(sample, volume: selectorView.volume, speed: selectorView.speed)
    }

    func instrumentViewWillSelectSample(_ instrumentView: InstrumentView, sample: Sample) {
        presenter.stopPlaying()
        presenter.playSample(sample, volume: selectorView.volume, speed: selectorView.speed)
    }

    func instrumentViewFailToSelect(_ instrumentView: InstrumentView) {
        presenter.stopPlaying()
    }

    func instrumentViewChangeExpand(_ instrumentView: InstrumentView, isExpanded: Bool) {
        [guitarView, drumView, brassView].forEach {
            if $0 !== instrumentView {
                $0?.isEnabled = !isExpanded
            }
        }
        selectorView.isUserInteractionEnabled = !isExpanded
        [layersButton, recordButton, playButton, voiceButton].forEach { $0?.isEnabled = !isExpanded }
    }
}

extension ViewController: SelectorViewDelegate {

    func selectorViewDidChanged(speed: Float, volume: Float) {
        presenter.update(volume: volume, speed: speed)
    }

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LayerCell else {
            return UITableViewCell()
        }

        let layer = layers[indexPath.row]

        cell.nameLabel.text = layer.sample.name
        cell.isMute = layer.muted
        cell.isPlaying = layer.active

        cell.onRemove = {
            self.presenter.remove(layer: layer)
        }

        cell.onPlay = {
            self.presenter.updatePlaying(cell.isPlaying, for: layer)
        }

        cell.onMute = {
            self.presenter.update(muted: cell.isMute, for: layer)
        }

        return cell
    }

}
