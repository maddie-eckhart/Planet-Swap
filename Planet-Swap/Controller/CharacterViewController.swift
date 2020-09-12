import UIKit

class CharacterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var alertView: UIView!
  @IBOutlet weak var topCollectionView: UICollectionView!
  @IBOutlet weak var bottomCollectionView: UICollectionView!
  @IBOutlet weak var saveButton: UIButton!
  
  @IBAction func saveButton(_ sender: Any) {
    dismiss(animated: true)
  }
  
  let topReuseIdentifier = "topCell"
  let bottomReuseIdentifier = "bottomCell"
  var selectedTop: CharacterCollectionViewCell?
  var selectedTopImage: UIImage?
  
  let topData: [CharacterModel] = [CharacterModel(image: UIImage(named: "alien1")!), CharacterModel(image: UIImage(named: "alien2")!), CharacterModel(image: UIImage(named: "alien3")!), CharacterModel(image: UIImage(named: "alien4")!), CharacterModel(image: UIImage(named: "alien5")!)]
  let bottomData: [CharacterModel] = [CharacterModel(image: UIImage(named: "alien1")!), CharacterModel(image: UIImage(named: "alien2")!), CharacterModel(image: UIImage(named: "alien3")!), CharacterModel(image: UIImage(named: "alien4")!), CharacterModel(image: UIImage(named: "alien5")!)]
  
  // MARK: App Lifestyle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    topCollectionView.dataSource = self
    topCollectionView.delegate = self
    topCollectionView.isPagingEnabled = true
    topCollectionView.showsHorizontalScrollIndicator = false
    topCollectionView.backgroundColor = UIColor.clear
    topCollectionView.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "topCell")
    if let flowLayout = self.topCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
    }
    bottomCollectionView.dataSource = self
    bottomCollectionView.delegate = self
    bottomCollectionView.isPagingEnabled = true
    bottomCollectionView.showsHorizontalScrollIndicator = false
    bottomCollectionView.backgroundColor = UIColor.clear
    bottomCollectionView.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "bottomCell")
    if let flowLayout = self.bottomCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
    }
  }
  
//  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//    let topCenterPoint = CGPoint(x: UIScreen.main.bounds.midX, y: 380)
//    var collectionViewCenterPoint = self.view.convert(topCenterPoint, to: topCollectionView)
//
//    if let indexPath = topCollectionView.indexPathForItem(at: collectionViewCenterPoint) {
//        let collectionViewCell = topCollectionView.cellForItem(at: indexPath)
////        collectionViewCell?.backgroundColor = UIColor.red
//    }
//
//    let bottomCenterPoint = CGPoint(x: UIScreen.main.bounds.midX, y: 520)
//    collectionViewCenterPoint = self.view.convert(bottomCenterPoint, to: bottomCollectionView)
//
//    if let indexPath = bottomCollectionView.indexPathForItem(at: collectionViewCenterPoint) {
//        let collectionViewCell = bottomCollectionView.cellForItem(at: indexPath)
////        collectionViewCell?.backgroundColor = UIColor.blue
//    }
//  }
//
//  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    scrollViewDidEndScrollingAnimation(scrollView)
//  }
//
//  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//    scrollViewDidEndScrollingAnimation(scrollView)
//  }
  
  // MARK: UICollectionViewDataSource
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CharacterCollectionViewCell
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    if collectionView == topCollectionView {
      // Top Cell
      selectedTop = cell
      selectedTopImage = cell.image.image
      cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
    } else {
      // Bottom Cell
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CharacterCollectionViewCell
    cell.backgroundColor = .clear
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView == topCollectionView {
      // Top Cell
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topReuseIdentifier, for: indexPath as IndexPath) as! CharacterCollectionViewCell
      cell.configure(with: topData[indexPath.row])
//      if cell.image == selectedTopImage {
//        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
//      } else {
//        cell.backgroundColor = UIColor.clear
//      }
      return cell
    } else {
      // Bottom Cell
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bottomReuseIdentifier, for: indexPath as IndexPath) as! CharacterCollectionViewCell
      cell.configure(with: bottomData[indexPath.row])
      cell.backgroundColor = UIColor.clear
      return cell
    }
  }
}

extension CharacterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      guard let cell: CharacterCollectionViewCell = Bundle.main.loadNibNamed("CharacterCell", owner: self, options: nil)?.first as? CharacterCollectionViewCell else {
            return CGSize.zero
        }
      
//      if collectionView == topCollectionView {
//        // Top Cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topReuseIdentifier, for: indexPath as IndexPath) as! CharacterCollectionViewCell
//        cell.configure(with: topData[indexPath.row])
//      } else {
//        // Bottom Cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bottomReuseIdentifier, for: indexPath as IndexPath) as! CharacterCollectionViewCell
//        cell.configure(with: bottomData[indexPath.row])
//      }
      
      cell.setNeedsLayout()
      cell.layoutIfNeeded()
      let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
      return CGSize(width: size.width, height: 128)
    }
}
