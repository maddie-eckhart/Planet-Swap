import UIKit

class LobbyViewController: UIViewController {

  @IBAction func Play(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "GameVC")
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil);
    
    if #available(iOS 13.0, *) {
      vc.isModalInPresentation = true
    } else {
      // Fallback on earlier versions
    }
  }
  
  @IBAction func Options(_ sender: Any) {
  }
  
  @IBAction func Quit(_ sender: Any) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 32/255, green: 9/255, blue: 112/255, alpha: 1)
    
    let viewMidX = view!.bounds.midX + 100
    let viewMidY = view!.bounds.midY + 100

    let sceneHeight = view!.frame.height
    let sceneWidth = view!.frame.width

    drawStars(viewMidX: viewMidX, viewMidY: viewMidY, sceneHeight: sceneHeight, sceneWidth: sceneWidth)
    
  }
  
  func drawStars(viewMidX: CGFloat, viewMidY: CGFloat, sceneHeight: CGFloat, sceneWidth: CGFloat) {
    for _ in 1...50 {
      let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10, y: 10), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = circlePath.cgPath
      shapeLayer.fillColor = UIColor.white.cgColor

      view.layer.addSublayer(shapeLayer)
            
      let xPosition = view!.frame.midX - viewMidX + CGFloat(arc4random_uniform(UInt32(viewMidX*2)))
      let yPosition = view!.frame.midY - viewMidY + CGFloat(arc4random_uniform(UInt32(viewMidY*2)))

      shapeLayer.position = CGPoint(x: xPosition, y: yPosition)
    }
  }

}
