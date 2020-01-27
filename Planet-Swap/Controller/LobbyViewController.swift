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
  }

}
