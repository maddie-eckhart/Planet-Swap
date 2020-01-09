import UIKit

class LobbyViewController: UIViewController {

  @IBAction func Play(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "GameVC")
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
    view.backgroundColor = UIColor(red: 255/255, green: 225/255, blue: 179/255, alpha: 1)
  }

}
