import UIKit

class SpaceAlertViewController: UIViewController {
  

  @IBOutlet weak var button1: UIButton!
  @IBOutlet weak var button2: UIButton!
  @IBOutlet weak var button3: UIButton!
  var alertType: SpaceAlertType?
  
  func getType() {
    switch alertType {
    case .Options:
      print("Options Alert")
      button1.titleLabel?.text = "MUSIC"
      button2.titleLabel?.text = "SOUNDS"
      button3.titleLabel?.text = "HELP"
    default:
      print("hello")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getType()
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    let backgroundCircle: UIView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 140, y: UIScreen.main.bounds.size.height/2 - 164, width: 280.0, height: 280.0))
    backgroundCircle.backgroundColor = UIColor(red: 119/255, green: 135/255, blue: 166/255, alpha: 1)
    backgroundCircle.layer.cornerRadius = 140
    backgroundCircle.layer.borderWidth = 10
    backgroundCircle.isUserInteractionEnabled = false
    backgroundCircle.layer.zPosition = -10
    if #available(iOS 13.0, *) {
      backgroundCircle.layer.borderColor = CGColor(srgbRed: 202/255, green: 216/255, blue: 241/255, alpha: 1)
    } else {
//      popup.layer.borderColor = UIColor.black.cgColor
    }
    view.addSubview(backgroundCircle)
  }

}

enum SpaceAlertType {
  case Options
  case BeginGame
  case EndGame
}
