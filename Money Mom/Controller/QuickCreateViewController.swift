import UIKit

class QuickCreateViewController: UIViewController {
    let tagCollectionView: UICollectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: TagCollectionViewFlowLayout())
    }()

    var tags: [String] = []
    var tagTextFieldText = ""
    var startCreatingTags = false
    var invisibleTagCollectionViewButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        addSubview(tagCollectionView: tagCollectionView)
    }

    private func addSubview(tagCollectionView: UICollectionView) {
        view.addSubview(tagCollectionView)
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        tagCollectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        tagCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        tagCollectionView.heightAnchor.constraint(equalToConstant: 44 * 3).isActive = true
        tagCollectionView.backgroundColor = MMColor.white
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self))
        tagCollectionView.register(TagTextFieldCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self))

        view.addSubview(invisibleTagCollectionViewButton)
        invisibleTagCollectionViewButton.translatesAutoresizingMaskIntoConstraints = false
        invisibleTagCollectionViewButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        invisibleTagCollectionViewButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        invisibleTagCollectionViewButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        invisibleTagCollectionViewButton.heightAnchor.constraint(equalToConstant: 44 * 3).isActive = true

        invisibleTagCollectionViewButton.addTarget(self, action: #selector(userWannaCreateTags), for: .touchUpInside)
    }
}

extension QuickCreateViewController {
    @objc func userWannaCreateTags() {
        invisibleTagCollectionViewButton.isHidden = true
        (tagCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
        startCreatingTags = true
    }
}

extension QuickCreateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self), for: indexPath) as? TagTextFieldCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self), for: indexPath) as? TagCollectionViewCell else {
                fatalError()
            }

            cell.label.text = tags[indexPath.row - 1]
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
            cell.textField.text = tagTextFieldText
            cell.textField.sizeToFit()

            return CGSize(width: min(cell.textField.frame.width + cell.layoutMargins.left + cell.layoutMargins.right, tagCollectionView.frame.width / 2), height: 50)
        } else {
            let cell = TagCollectionViewCell()
            cell.label.text = tags[indexPath.row - 1]
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
