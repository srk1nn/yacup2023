//
//  LayerCell.swift
//  YaCup
//
//  Created by igor.sorokin on 02.11.2023.
//

import UIKit

final class LayerCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var bgView: UIView!

    var isPlaying: Bool = false {
        didSet {
            bgView.backgroundColor = isPlaying ? .secondary : .white
            let image = isPlaying ? "pause" : "play"
            playButton.setImage(.init(named: image), for: .normal)
        }
    }

    var isMute: Bool = false {
        didSet {
            let image = isMute ? "mute" : "vol"
            muteButton.setImage(.init(named: image), for: .normal)
        }
    }

    var onRemove: VoidClosure?
    var onPlay: VoidClosure?
    var onMute: VoidClosure?

    override func prepareForReuse() {
        onRemove = nil
        onPlay = nil
        onMute = nil

        bgView.backgroundColor = .white
    }

    override func awakeFromNib() {
        selectionStyle = .none
        backgroundColor = .clear
        nameLabel.textColor = .black

        removeButton.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(didTapMute), for: .touchUpInside)
    }

    @objc
    private func didTapRemove() {
        onRemove?()
    }

    @objc
    private func didTapPlay() {
        isPlaying.toggle()
        onPlay?()
    }

    @objc
    private func didTapMute() {
        isMute.toggle()
        onMute?()
    }
}
