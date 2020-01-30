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
    let viewMidX = view!.bounds.midX * 2
    let viewMidY = view!.bounds.midY * 2
    
    let viewWidth = view.frame.width
    let viewHeight = view.frame.height
    
    let skyView = UIView(frame: CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 50, height: 50))
    //skyView.backgroundColor = UIColor.red
    skyView.drawStars(midX: viewMidX, midY: viewMidY)
    skyView.rotate360Degrees(duration: 190)
    self.view.addSubview(skyView)
    
  }

}

extension UIView {
  func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = 0.0
    rotateAnimation.toValue = CGFloat(.pi * 2.0)
    rotateAnimation.duration = duration
    rotateAnimation.repeatCount = .infinity
 
    if let delegate: AnyObject = completionDelegate {
      rotateAnimation.delegate = delegate as? CAAnimationDelegate
    }
    
    self.layer.add(rotateAnimation, forKey: nil)
    }
  
  func drawStars(midX: CGFloat, midY: CGFloat) {
    for _ in 1...100 {
      let starPath = UIBezierPath(arcCenter: CGPoint(x: -self.frame.width * 10, y: -self.frame.height * 10), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
      let skyLayer = CAShapeLayer()
      skyLayer.path = starPath.cgPath
      skyLayer.fillColor = UIColor.white.cgColor

      self.layer.addSublayer(skyLayer)
            
      let xPosition = midX - midX + CGFloat(arc4random_uniform(UInt32(midX*2)))
      let yPosition = midY - midY + CGFloat(arc4random_uniform(UInt32(midY*2)))

      skyLayer.position = CGPoint(x: xPosition, y: yPosition)
      skyLayer.zPosition = -10
    }
    
    for _ in 1...200 {
      let starPath = UIBezierPath(arcCenter: CGPoint(x: -self.frame.width * 10, y: -self.frame.height * 10), radius: CGFloat(1), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
      let skyLayer = CAShapeLayer()
      skyLayer.path = starPath.cgPath
      skyLayer.fillColor = UIColor.white.cgColor

      self.layer.addSublayer(skyLayer)
            
      let xPosition = midX - midX + CGFloat(arc4random_uniform(UInt32(midX*2)))
      let yPosition = midY - midY + CGFloat(arc4random_uniform(UInt32(midY*2)))

      skyLayer.position = CGPoint(x: xPosition, y: yPosition)
      skyLayer.zPosition = -10
    }
  }
}
