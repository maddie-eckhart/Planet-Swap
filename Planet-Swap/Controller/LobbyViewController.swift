import UIKit

class LobbyViewController: UIViewController {

  @IBAction func SaveTgw(sender: AnyObject) {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "GameVC")
    self.present(vc, animated: true, completion: nil);
    if #available(iOS 13.0, *) {
      vc.isModalInPresentation = true
    } else {
      // Fallback on earlier versions
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
