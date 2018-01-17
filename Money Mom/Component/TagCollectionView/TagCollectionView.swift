import UIKit

class TagCollectionView: UICollectionView {
  static func horizontalLayout() -> TagCollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return TagCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
  }

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    backgroundColor = MMColor.white
    register(TagCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self))
    register(TagTextFieldCollectionViewCell.self,
             forCellWithReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self))
    register(ReadOnlyTagCollectionViewCell.self,
             forCellWithReuseIdentifier: NSStringFromClass(ReadOnlyTagCollectionViewCell.self))
  }

  convenience init() {
    self.init(frame: CGRect.zero, collectionViewLayout: TagCollectionViewFlowLayout())
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TagCollectionView {
  func dequeueReusableCell(forTagAt indexPath: IndexPath) -> TagCollectionViewCell? {
    return super.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagCollectionViewCell.self),
                                     for: indexPath) as? TagCollectionViewCell
  }

  func dequeueReusableCell(forReadOnlyTagAt indexPath: IndexPath) -> ReadOnlyTagCollectionViewCell? {
    return super.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ReadOnlyTagCollectionViewCell.self),
                                     for: indexPath) as? ReadOnlyTagCollectionViewCell
  }

  func dequeueReusableCell(forTagTextFieldAt indexPath: IndexPath) -> TagTextFieldCollectionViewCell? {
    return super.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TagTextFieldCollectionViewCell.self),
                                     for: indexPath) as? TagTextFieldCollectionViewCell
  }
}
