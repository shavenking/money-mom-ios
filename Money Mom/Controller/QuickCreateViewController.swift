import UIKit
import AVFoundation

protocol QuickRecordDelegate {
    func didAdd(quickRecord: QuickRecord)
}

class QuickCreateViewController: UIViewController {
    let amountTextField = AmountTextField()

    lazy var tagCollectionView: TagCollectionView = {
        var tagCollectionView = TagCollectionView()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userWannaCreateTags)))
        return tagCollectionView
    }()

    lazy var recordButton: RecordButton = {
        var button = RecordButton()
        button.delegate = self
        return button
    }()

    var audioUUID = UUID()

    lazy var audioRecorder: AVAudioRecorder? = {
        guard let audioFilePath = MMConfig.audioFilePath(of: audioUUID) else {
            return nil
        }

        do {
            var audioRecorder =  try AVAudioRecorder(url: audioFilePath, settings: MMConfig.recordingSettings)

            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()

            return audioRecorder
        } catch {
            return nil
        }
    }()

    var player: AVAudioPlayer?

    var tags: [String] = []
    var tagTextFieldText = ""
    var startCreatingTags = false
    var delegate: QuickRecordDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))

        addSubviews()
    }

    private func addSubviews() {
        view.addSubview(amountTextField)
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        amountTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        amountTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        view.addSubview(tagCollectionView)
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        tagCollectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        tagCollectionView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 10).isActive = true
        tagCollectionView.heightAnchor.constraint(equalToConstant: 44 * 3).isActive = true

        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor, constant: 10).isActive = true
        recordButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        recordButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension QuickCreateViewController {
    @objc func userWannaCreateTags() {
        (tagCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
        startCreatingTags = true
    }

    @objc func save() {
        let quickRecord = QuickRecord(amount: amountTextField.text ?? "", tags: tags, audioUUID: audioUUID)

        delegate?.didAdd(quickRecord: quickRecord)

        navigationController?.popViewController(animated: true)
    }
}

extension QuickCreateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = (collectionView as! TagCollectionView).dequeueReusableCell(forTagTextFieldAt: indexPath)

            cell.delegate = self

            return cell
        } else {
            let cell = (collectionView as! TagCollectionView).dequeueReusableCell(forTagAt: indexPath)

            cell.tagData = tags[indexPath.row - 1]
            cell.delegate = self

            return cell
        }
    }
}

extension QuickCreateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if startCreatingTags, cell is TagTextFieldCollectionViewCell {
            (cell as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let cell = TagTextFieldCollectionViewCell()
            cell.text = tagTextFieldText

            return CGSize(width: min(cell.textField.frame.width + cell.layoutMargins.left + cell.layoutMargins.right, tagCollectionView.frame.width / 2), height: 50)
        } else {
            let cell = TagCollectionViewCell()
            cell.tagData = tags[indexPath.row - 1]
            cell.label.sizeToFit()

            return CGSize(width: min(cell.label.frame.width + cell.button.frame.width + cell.layoutMargins.right + cell.layoutMargins.left, tagCollectionView.frame.width / 2), height: 50);
        }
    }
}

extension QuickCreateViewController: TagTextFieldDelegate {
    func didAdd(tag: String) {
        tags.insert(tag, at: 0)
        tagCollectionView.reloadData()
    }

    func didChange(text: String) {
        tagTextFieldText = text
        tagCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension QuickCreateViewController: TagCollectionViewCellDelegate {
    func didTouchButton(in tag: TagCollectionViewCell) {
        tags = tags.filter { $0 != tag.label.text }
        tagCollectionView.reloadData()
    }
}

extension QuickCreateViewController: RecordButtonDelegate, AVAudioRecorderDelegate {
    func userWannaStartRecording() {
        let session = AVAudioSession.sharedInstance()

        session.requestRecordPermission { allowed in
            if allowed {
                do {
                    try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                    try session.setActive(true)
                } catch {
                    fatalError("failed to start recording")
                }

                self.audioRecorder?.record()
                self.recordButton.setStyleForRecording()
            }
        }
    }

    func userWannaStopRecording() {
        audioRecorder?.stop()
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setDefaultStyle()

        if flag {
            if let audioFilePath = MMConfig.audioFilePath(of: audioUUID) {
                do {
                    player = try AVAudioPlayer(contentsOf: audioFilePath)
                    player?.prepareToPlay()
                    player?.play()
                } catch {
                    fatalError("Cannot play audio")
                }
            }
        }
    }
}
