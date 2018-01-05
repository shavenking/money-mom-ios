import UIKit
import AVFoundation

protocol TransactionTableViewCellDelegate {
    func userWannaEdit(transaction: Transaction)
}

class TransactionTableViewCell: UITableViewCell {
    var delegate: TransactionTableViewCellDelegate?

    private lazy var editButton: UIButton = {
        let editButton = UIButton()
        editButton.setTitleColor(MMColor.black, for: .normal)
        editButton.setTitle("EDIT", for: .normal)
        editButton.sizeToFit()
        editButton.addTarget(self, action: #selector(userWannaEdit), for: .touchUpInside)

        return editButton
    }()

    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setTitleColor(MMColor.white, for: .normal)
        deleteButton.setTitle("DELETE", for: .normal)
        deleteButton.sizeToFit()
        deleteButton.addTarget(self, action: #selector(userWannaDelete), for: .touchUpInside)

        return deleteButton
    }()

    private lazy var hiddenView: UIView = {
        let deleteView = UIView()
        deleteView.layoutMargins = contentView.layoutMargins

        return deleteView
    }()

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

    var transaction: Transaction? {
        didSet {
            guard let transaction = self.transaction else {
                return
            }

            amountLabel.text = "$\(transaction.amount == NSDecimalNumber.notANumber ? NSDecimalNumber.zero : transaction.amount)"
            tags = transaction.tags

            if transaction.type == .INCOME {
                amountLabel.textColor = MMColor.black
                amountLabel.backgroundColor = MMColor.green
                playButton.setTitleColor(MMColor.black, for: .normal)
                playButton.backgroundColor = MMColor.green
            } else {
                amountLabel.textColor = MMColor.white
                amountLabel.backgroundColor = MMColor.red
                playButton.setTitleColor(MMColor.white, for: .normal)
                playButton.backgroundColor = MMColor.red
            }

            if let audioFilePath = MMConfig.audioFilePath(of: transaction.audioUUID) {
                do {
                    player = try AVAudioPlayer(contentsOf: audioFilePath)
                    player?.delegate = self
                } catch {
                    player = nil
                }
            }
        }
    }

    private let topInnerView: UIView = {
        let topInnerView = UIView()
        topInnerView.layer.cornerRadius = 4
        topInnerView.layer.masksToBounds = true
        topInnerView.layoutMargins = .zero
        return topInnerView
    }()

    private lazy var mainView: UIView = {
        let mainView = UIView()
        mainView.backgroundColor = MMColor.white
        mainView.layoutMargins = contentView.layoutMargins
        return mainView
    }()

    private var mainViewLeftAnchor: NSLayoutConstraint?

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        topInnerView.addSubview(amountLabel)
        topInnerView.addSubview(playButton)

        mainView.addSubview(topInnerView)
        mainView.addSubview(tagCollectionView)

        hiddenView.addSubview(editButton)
        hiddenView.addSubview(deleteButton)

        contentView.addSubview(hiddenView)
        contentView.addSubview(mainView)

        hiddenView.translatesAutoresizingMaskIntoConstraints = false
        hiddenView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        hiddenView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        hiddenView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        hiddenView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.topAnchor).isActive = true
        editButton.bottomAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.bottomAnchor).isActive = true
        editButton.leftAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.leftAnchor).isActive = true

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.bottomAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: hiddenView.layoutMarginsGuide.rightAnchor).isActive = true

        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        mainView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainViewLeftAnchor = mainView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        mainViewLeftAnchor?.isActive = true

        topInnerView.translatesAutoresizingMaskIntoConstraints = false
        topInnerView.topAnchor.constraint(equalTo: mainView.layoutMarginsGuide.topAnchor).isActive = true
        topInnerView.leftAnchor.constraint(equalTo: mainView.layoutMarginsGuide.leftAnchor).isActive = true
        topInnerView.rightAnchor.constraint(equalTo: mainView.layoutMarginsGuide.rightAnchor).isActive = true
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
        tagCollectionView.leftAnchor.constraint(equalTo: mainView.layoutMarginsGuide.leftAnchor).isActive = true
        tagCollectionView.rightAnchor.constraint(equalTo: mainView.layoutMarginsGuide.rightAnchor).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: mainView.layoutMarginsGuide.bottomAnchor).isActive = true

        addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mainViewLeftAnchor?.constant = 0
    }
}

extension TransactionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension TransactionTableViewCell {
    @objc func playAudio() {
        player?.play()
    }
}

extension TransactionTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try! AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
    }
}

extension TransactionTableViewCell {
    @objc private func panGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: contentView)

            mainViewLeftAnchor?.constant += translation.x

            if (mainViewLeftAnchor?.constant ?? 0) < 0 {
                hiddenView.backgroundColor = MMColor.red
                deleteButton.isHidden = false
                editButton.isHidden = true
            } else {
                hiddenView.backgroundColor = MMColor.green
                deleteButton.isHidden = true
                editButton.isHidden = false
            }

            sender.setTranslation(.zero, in: contentView)
        }

        if sender.state == .ended, let mainViewLeftAnchor = mainViewLeftAnchor {
            contentView.layoutIfNeeded()

            if mainViewLeftAnchor.constant < 0, abs(mainViewLeftAnchor.constant) >= deleteButton.frame.width {
                mainViewLeftAnchor.constant = -deleteButton.frame.width - contentView.layoutMargins.right
            } else if mainViewLeftAnchor.constant > 0, abs(mainViewLeftAnchor.constant) >= editButton.frame.width {
                mainViewLeftAnchor.constant = editButton.frame.width + contentView.layoutMargins.left
            } else {
                mainViewLeftAnchor.constant = 0
            }

            UIView.animate(withDuration: 0.2) { () in
                self.contentView.layoutIfNeeded()
            }
        }
    }
}

extension TransactionTableViewCell {
    @objc private func userWannaDelete() {
        guard let transaction = transaction else {
            return
        }

        contentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.mainViewLeftAnchor?.constant = -self.contentView.frame.width
            self.contentView.layoutIfNeeded()
        }) { finished in
            if finished {
                let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer!.viewContext
                viewContext.delete(transaction)
                try! viewContext.save()
            }
        }
    }

    @objc private func userWannaEdit() {
        contentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.mainViewLeftAnchor?.constant = self.contentView.frame.width
            self.contentView.layoutIfNeeded()
        }) { finished in
            if finished {
                if let transaction = self.transaction {
                    self.delegate?.userWannaEdit(transaction: transaction)
                    self.mainViewLeftAnchor?.constant = 0
                }
            }
        }
    }
}

extension TransactionTableViewCell {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer, let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: contentView) {
            return abs(velocity.x) > abs(velocity.y)
        }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
