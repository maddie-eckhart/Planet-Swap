import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet var image: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  public func configure(with model: CharacterModel) {
    image.image = model.image
  }
}

struct CharacterModel {
  let image: UIImage
}
