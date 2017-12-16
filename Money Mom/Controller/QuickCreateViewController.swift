import UIKit

class QuickCreateViewController: UIViewController {
    let tagCollectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var tags: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MMColor.white

        addSubview(tagCollectionView: tagCollectionView)
    }

    private func addSubview(tagCollectionView: UICollectionView) {
        view.addSubview(tagCollectionView)
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tagCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tagCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        tagCollectionView.heightAnchor.constraint(equalToConstant: 44 * 3).isActive = true
        tagCollectionView.backgroundColor = MMColor.black
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self))
        tagCollectionView.register(TagTextFieldCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self))
    }
}

extension QuickCreateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == tags.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self), for: indexPath) as? TagTextFieldCollectionViewCell else {
                fatalError()
            }

            cell.backgroundColor = MMColor.red
            cell.delegate = self

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self), for: indexPath) as? TagCollectionViewCell else {
                fatalError()
            }

            cell.backgroundColor = MMColor.white
            cell.label.text = tags[indexPath.row]

            return cell
        }
    }
}

extension QuickCreateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? TagTextFieldCollectionViewCell)?.textField.becomeFirstResponder()
    }
}

extension QuickCreateViewController: TagTextFieldDelegate {
    func didAdd(tag: String) {
        tags.append(tag)
        tagCollectionView.reloadData()
    }
}
