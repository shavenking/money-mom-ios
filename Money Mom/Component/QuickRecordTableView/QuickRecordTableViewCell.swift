import UIKit
import AVFoundation

class QuickRecordTableViewCell: UITableViewCell {
    let amountLabel = AmountLabel.large()

    let playButton = PlayButton()

    var player: AVAudioPlayer? {
        didSet {
            if player == nil {
                playButton.setUnavailableToPlayStyle()
            } else {
                playButton.setAvailableToPlayStyle()
            }
        }
    }

    var tags = Set<String>() {
        didSet {
            if tags.isEmpty {
                tagCollectionView.backgroundColor = MMColor.black.withAlphaComponent(0.1)
                tagCollectionView.reloadData()
            } else {
                tagCollectionView.backgroundColor = MMColor.white
                tagCollectionView.reloadData()
            }
        }
    }

    lazy var tagCollectionView: TagCollectionView = {
        var tagCollectionView = TagCollectionView.horizontalLayout()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self

        return tagCollectionView
    }()

    var quickRecord: QuickRecord? {
        didSet {
            guard let quickRecord = self.quickRecord else {
                return
            }

            amountLabel.text = "$\(quickRecord.amount)"
            tags = quickRecord.tags

            if let audioFilePath = MMConfig.audioFilePath(of: quickRecord.audioUUID) {
                do {
                    player = try AVAudioPlayer(contentsOf: audioFilePath)
                    player?.delegate = self
                } catch {
                    player = nil
                }
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let topInnerView = UIView()
        topInnerView.layer.cornerRadius = 4
        topInnerView.layer.masksToBounds = true
        topInnerView.layoutMargins = .zero

        topInnerView.addSubview(amountLabel)
        topInnerView.addSubview(playButton)

        contentView.addSubview(topInnerView)
        contentView.addSubview(tagCollectionView)

        topInnerView.translatesAutoresizingMaskIntoConstraints = false
        topInnerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        topInnerView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        topInnerView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        topInnerView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.topAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.topAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.bottomAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.rightAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        playButton.setContentCompressionResistancePriority(.required, for: .vertical)
        playButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.topAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.topAnchor).isActive = true
        amountLabel.bottomAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.bottomAnchor).isActive = true
        amountLabel.leftAnchor.constraint(equalTo: topInnerView.layoutMarginsGuide.leftAnchor).isActive = true
        amountLabel.rightAnchor.constraint(equalTo: playButton.leftAnchor).isActive = true
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.topAnchor.constraint(equalTo: topInnerView.bottomAnchor).isActive = true
        tagCollectionView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        tagCollectionView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        tagCollectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuickRecordTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView as! TagCollectionView).dequeueReusableCell(forReadOnlyTagAt: indexPath)

        cell.tagData = tags.sorted()[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = ReadOnlyTagCollectionViewCell()
        cell.tagData = tags.sorted()[indexPath.row]

        return CGSize(width: min(cell.label.frame.width + cell.layoutMargins.right + cell.layoutMargins.left, tagCollectionView.frame.width / 2), height: 50);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension QuickRecordTableViewCell {
    @objc func playAudio() {
        player?.play()
    }
}

extension QuickRecordTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try! AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
    }
}
