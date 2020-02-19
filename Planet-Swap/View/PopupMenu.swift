import UIKit

class PopupMenu: UIView {

    func setup() {
      // View setup
      let popup : UIView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 - 250, width: 300.0, height: 400.0))
      popup.backgroundColor = UIColor(red: 202/255, green: 216/255, blue: 241/255, alpha: 1)
      popup.layer.cornerRadius = 40
      popup.layer.borderWidth = 12
      if #available(iOS 13.0, *) {
        popup.layer.borderColor = CGColor(srgbRed: 255/255, green: 91/255, blue: 92/255, alpha: 1)
      } else {
        popup.layer.borderColor = UIColor.black.cgColor
      }
      addSubview(popup)
      
      // Close button setup
      let closeButton = UIButton(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
      closeButton.backgroundColor = .green
      closeButton.layer.cornerRadius = closeButton.bounds.size.width/2
      closeButton.setTitle("x", for: .normal)
      closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
      popup.addSubview(closeButton)
      
    }
  
  @objc func closeButtonAction() {
    print("close")
  }

}
