import UIKit
import AVFoundation

class QuickRecordTableViewCell: UITableViewCell {
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = MMColor.white
        label.backgroundColor = MMColor.black
        label.textAlignment = .center
        return label
    }()

    let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("▶", for: .normal)
        button.setTitleColor(MMColor.white, for: .normal)
        button.backgroundColor = MMColor.black
        return button
    }()

    var tags = [String]() {
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

    let tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }()

    var player: AVAudioPlayer? {
        didSet {
            if player == nil {
                playButton.setTitle("⤫", for: .normal)
                playButton.isUserInteractionEnabled = false
            } else {
                playButton.setTitle("▶", for: .normal)
                playButton.isUserInteractionEnabled = true
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

        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.backgroundColor = MMColor.white
        tagCollectionView.register(ReadOnlyTagCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ReadOnlyTagCollectionViewCell.self))
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ReadOnlyTagCollectionViewCell.self), for: indexPath) as! ReadOnlyTagCollectionViewCell

        cell.label.text = tags[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = ReadOnlyTagCollectionViewCell()
        cell.label.text = tags[indexPath.row]
        cell.label.sizeToFit()

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
