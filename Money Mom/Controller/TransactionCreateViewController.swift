import UIKit
import AVFoundation
import CoreData

// swiftlint:disable type_body_length file_length
class TransactionCreateViewController: UIViewController {
  var editingTransaction: Transaction?
  let amountTextField = AmountTextField()
  lazy var recordButton: RecordButton = {
    var button = RecordButton()
    button.delegate = self
    return button
  }()
  let tempAudioUUID = UUID()
  lazy var audioRecorder: AVAudioRecorder? = {
    guard let audioFilePath = MMConfig.audioFileURL(of: tempAudioUUID) else {
      return nil
    }
    do {
      var audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: MMConfig.recordingSettings)
      audioRecorder.delegate = self
      audioRecorder.prepareToRecord()
      return audioRecorder
    } catch {
      return nil
    }
  }()
  var tags = Set<Tag>()
  var tagTextFieldText = ""
  var startCreatingTags = false
  lazy var tagCollectionView: TagCollectionView = {
    var tagCollectionView = TagCollectionView.horizontalLayout()
    tagCollectionView.dataSource = self
    tagCollectionView.delegate = self
    tagCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userWannaCreateTags)))
    return tagCollectionView
  }()
  let moreButton: UIButton = {
    let moreButton = UIButton()
    moreButton.layer.cornerRadius = 4
    moreButton.layer.masksToBounds = true
    moreButton.setTitle("點我輸入更多資料", for: .normal)
    moreButton.setTitleColor(MMColor.black, for: .normal)
    moreButton.backgroundColor = MMColor.blue.withAlphaComponent(0.3)
    moreButton.addTarget(self, action: #selector(userWannaAddMoreInfo), for: .touchUpInside)
    return moreButton
  }()
  let datePicker: UIDatePicker = {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .dateAndTime
    datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    return datePicker
  }()
  lazy var dateTextField: UITextField = {
    let dateTextField = UITextField()
    dateTextField.isHidden = true
    dateTextField.inputView = datePicker
    dateTextField.textColor = MMColor.black
    dateTextField.leftViewMode = .always
    dateTextField.leftView = {
      let leftViewLabel = UILabel()
      leftViewLabel.text = "日期："
      leftViewLabel.sizeToFit()
      leftViewLabel.textColor = MMColor.black
      return leftViewLabel
    }()
    return dateTextField
  }()
  lazy var locationTextField: UITextField = {
    let locationTextField = UITextField()
    locationTextField.isHidden = true
    locationTextField.textColor = MMColor.black
    locationTextField.leftViewMode = .always
    locationTextField.leftView = {
      let leftViewLabel = UILabel()
      leftViewLabel.text = "地點："
      leftViewLabel.sizeToFit()
      leftViewLabel.textColor = MMColor.black
      return leftViewLabel
    }()
    return locationTextField
  }()
  let transactionTypeLabel: UILabel = {
    let transactionTypeLabel = UILabel()
    transactionTypeLabel.isHidden = true
    transactionTypeLabel.text = "分類："
    transactionTypeLabel.textColor = MMColor.black
    transactionTypeLabel.sizeToFit()
    return transactionTypeLabel
  }()
  lazy var transactionTypeSegmentedControl: UISegmentedControl = {
    let transactionTypeSegmentedControl = UISegmentedControl()
    transactionTypeSegmentedControl.isHidden = true
    transactionTypeSegmentedControl.tintColor = MMColor.black
    transactionTypeSegmentedControl.insertSegment(withTitle: "收入", at: 0, animated: false)
    transactionTypeSegmentedControl.insertSegment(withTitle: "支出", at: 1, animated: false)
    transactionTypeSegmentedControl.addTarget(self, action: #selector(transactionTypeChanged), for: .valueChanged)
    return transactionTypeSegmentedControl
  }()

  convenience init(transaction: Transaction) {
    self.init()
    editingTransaction = transaction
    amountTextField.text = transaction.amount.stringValue
    tags = transaction.tags
    datePicker.setDate(transaction.date, animated: false)
    locationTextField.text = transaction.location
    transactionTypeSegmentedControl.selectedSegmentIndex = Int(transaction.type.rawValue)
    tagCollectionView.reloadData()
    userWannaAddMoreInfo()
    datePickerValueChanged()
    transactionTypeChanged()
  }

  // swiftlint:disable function_body_length
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                        target: self,
                                                        action: #selector(save))
    view.backgroundColor = MMColor.white
    view.addSubview(amountTextField)
    view.addSubview(recordButton)
    view.addSubview(tagCollectionView)
    view.addSubview(moreButton)
    view.addSubview(dateTextField)
    view.addSubview(locationTextField)
    view.addSubview(transactionTypeLabel)
    view.addSubview(transactionTypeSegmentedControl)
    amountTextField.translatesAutoresizingMaskIntoConstraints = false
    recordButton.translatesAutoresizingMaskIntoConstraints = false
    tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
    moreButton.translatesAutoresizingMaskIntoConstraints = false
    dateTextField.translatesAutoresizingMaskIntoConstraints = false
    locationTextField.translatesAutoresizingMaskIntoConstraints = false
    transactionTypeLabel.translatesAutoresizingMaskIntoConstraints = false
    transactionTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
    amountTextField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
    amountTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    amountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    amountTextField.rightAnchor.constraint(equalTo: recordButton.leftAnchor).isActive = true
    tagCollectionView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 8).isActive = true
    tagCollectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    tagCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    tagCollectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    recordButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
    recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor).isActive = true
    recordButton.bottomAnchor.constraint(equalTo: amountTextField.bottomAnchor).isActive = true
    recordButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    moreButton.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor, constant: 8).isActive = true
    moreButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    moreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    moreButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    dateTextField.topAnchor.constraint(equalTo: moreButton.topAnchor).isActive = true
    dateTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    dateTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    dateTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    locationTextField.topAnchor.constraint(equalTo: dateTextField.bottomAnchor).isActive = true
    locationTextField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    locationTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    locationTextField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
    transactionTypeLabel.topAnchor.constraint(equalTo: locationTextField.bottomAnchor).isActive = true
    transactionTypeLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    transactionTypeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    transactionTypeSegmentedControl.topAnchor.constraint(equalTo: locationTextField.bottomAnchor).isActive = true
    transactionTypeSegmentedControl.leftAnchor.constraint(equalTo: transactionTypeLabel.rightAnchor).isActive = true
    transactionTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    transactionTypeSegmentedControl.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    amountTextField.becomeFirstResponder()
    datePickerValueChanged()
  }

  @objc private func datePickerValueChanged() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.timeZone = TimeZone.current
    dateTextField.text = formatter.string(from: datePicker.date)
  }

  @objc private func transactionTypeChanged() {
    if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
      transactionTypeSegmentedControl.tintColor = MMColor.green
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.black
                                                             ], for: .normal)
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.black
                                                             ], for: .selected)
    } else if transactionTypeSegmentedControl.selectedSegmentIndex == 1 {
      transactionTypeSegmentedControl.tintColor = MMColor.red
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.black
                                                             ], for: .normal)
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.white
                                                             ], for: .selected)
    } else {
      transactionTypeSegmentedControl.tintColor = MMColor.black
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.black
                                                             ], for: .normal)
      transactionTypeSegmentedControl.setTitleTextAttributes([
                                                               NSAttributedStringKey.foregroundColor: MMColor.black
                                                             ], for: .selected)
    }
  }

  @objc private func userWannaAddMoreInfo() {
    moreButton.isHidden = true
    dateTextField.isHidden = false
    locationTextField.isHidden = false
    transactionTypeLabel.isHidden = false
    transactionTypeSegmentedControl.isHidden = false
    dateTextField.alpha = 0
    locationTextField.alpha = 0
    transactionTypeLabel.alpha = 0
    transactionTypeSegmentedControl.alpha = 0
    UIView.animate(withDuration: 0.3) {
      self.dateTextField.alpha = 1
      self.locationTextField.alpha = 1
      self.transactionTypeLabel.alpha = 1
      self.transactionTypeSegmentedControl.alpha = 1
    }
  }

  // swiftlint:disable cyclomatic_complexity
  @objc private func save() {
    var amount = NSDecimalNumber(string: amountTextField.text)
    if amount == .notANumber {
      amount = .zero
    }
    if !tagTextFieldText.isEmpty {
      didAdd(tagName: tagTextFieldText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    guard let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext else {
      fatalError("failed to get ViewContext from AppDelegate")
    }
    if let editingTransaction = self.editingTransaction {
      editingTransaction.amount = amount
      if let audioFileURL = MMConfig.audioFileURL(of: tempAudioUUID),
         FileManager.default.fileExists(atPath: audioFileURL.path) {
        editingTransaction.audioUUID = tempAudioUUID
      }
      editingTransaction.date = datePicker.date
      editingTransaction.location = locationTextField.text ?? ""
      editingTransaction.tags = tags
      if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
        editingTransaction.type = .INCOME
      } else if transactionTypeSegmentedControl.selectedSegmentIndex == 1 {
        editingTransaction.type = .EXPENSE
      } else {
        editingTransaction.type = .UNKNOWN
      }
    } else {
      guard let transaction = NSEntityDescription.insertNewObject(forEntityName: String(describing: Transaction.self),
                                                                  into: viewContext) as? Transaction else {
        fatalError("Insert Transaction Failed")
      }
      transaction.amount = amount
      if let audioFileURL = MMConfig.audioFileURL(of: tempAudioUUID),
         FileManager.default.fileExists(atPath: audioFileURL.path) {
        transaction.audioUUID = tempAudioUUID
      }
      transaction.date = datePicker.date
      transaction.location = locationTextField.text ?? ""
      transaction.tags = tags
      if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
        transaction.type = .INCOME
      } else if transactionTypeSegmentedControl.selectedSegmentIndex == 1 {
        transaction.type = .EXPENSE
      } else {
        transaction.type = .UNKNOWN
      }
    }
    do {
      try viewContext.save()
    } catch {
      fatalError(error.localizedDescription)
    }
    navigationController?.popToRootViewController(animated: true)
  }
}

extension TransactionCreateViewController: RecordButtonDelegate, AVAudioRecorderDelegate {
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
    do {
      try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

extension TransactionCreateViewController: UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout,
                                           TagTextFieldDelegate,
                                           TagCollectionViewCellDelegate {
  @objc func userWannaCreateTags() {
    (tagCollectionView.cellForItem(
      at: IndexPath(item: 0, section: 0)) as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
    startCreatingTags = true
  }

  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    if startCreatingTags, cell is TagTextFieldCollectionViewCell {
      (cell as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
    }
  }

  func collectionView(_ collectionView: UICollectionView,
                      didEndDisplaying cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    if startCreatingTags, cell is TagTextFieldCollectionViewCell {
      (cell as? TagTextFieldCollectionViewCell)?.textField.resignFirstResponder()
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tags.count + 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.row == 0 {
      guard let cell = (collectionView as? TagCollectionView)?.dequeueReusableCell(forTagTextFieldAt: indexPath) else {
        fatalError("can not dequeue TagTextField cell from TagCollectionView")
      }
      cell.delegate = self
      return cell
    } else {
      guard let cell = (collectionView as? TagCollectionView)?.dequeueReusableCell(forTagAt: indexPath) else {
        fatalError("can not dequeue cell from TagCollectionView")
      }
      cell.tagData = tags.sorted()[indexPath.row - 1]
      cell.delegate = self
      return cell
    }
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.row == 0 {
      let cell = TagTextFieldCollectionViewCell()
      cell.text = tagTextFieldText
      return CGSize(width: min(cell.textField.frame.width + cell.layoutMargins.left + cell.layoutMargins.right,
                               tagCollectionView.frame.width / 2),
                    height: 50)
    } else {
      let cell = TagCollectionViewCell()
      cell.tagData = tags.sorted()[indexPath.row - 1]
      cell.label.sizeToFit()
      return CGSize(width: min(
        cell.label.frame.width + cell.button.frame.width + cell.layoutMargins.right + cell.layoutMargins.left,
        tagCollectionView.frame.width / 2),
                    height: 50)
    }
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  func didAdd(tagName: String) {
    guard let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext else {
      fatalError("can not get ViewContext from AppDelegate")
    }
    let request = NSFetchRequest<Tag>(entityName: String(describing: Tag.self))
    request.predicate = NSPredicate(format: "\(#keyPath(Tag.name)) = %@", argumentArray: [tagName])
    if let tag = try viewContext.fetch(request).first {
      tags.insert(tag)
    } else {
      guard let tag = NSEntityDescription.insertNewObject(forEntityName: String(describing: Tag.self),
                                                    into: viewContext) as? Tag else {
        fatalError("can not insert new Tag")
      }
      tag.name = tagName
      tags.insert(tag)
    }
    tagCollectionView.reloadData()
  }

  func didChange(text: String) {
    tagTextFieldText = text
    tagCollectionView.collectionViewLayout.invalidateLayout()
  }

  func didTouchButton(in cell: TagCollectionViewCell) {
    if let tag = cell.tagData {
      tags.remove(tag)
      tagCollectionView.reloadData()
    }
  }
}
