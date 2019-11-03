import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  
  // MARK: Properties
  
  // The scene draws the tiles and cookie sprites, and handles swipes.
  var scene: GameScene!
  var level: Level!
  
  var movesLeft = 0
  var score = 0
  
  lazy var backgroundMusic: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = -1
      return player
    } catch {
      return nil
    }
  }()
  
  // MARK: IBOutlets
  @IBOutlet weak var gameOverPanel: UIImageView!
  @IBOutlet weak var targetLabel: UILabel!
  @IBOutlet weak var movesLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var shuffleButton: UIButton!
  
  @IBAction func shuffleButtonPressed(_: AnyObject) {}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the view
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    //Create the level
    level = Level(filename: "Level_1")
    scene.level = level
    
    scene.swipeHandler = handleSwipe
    
    // Present the scene.
    skView.presentScene(scene)
    scene.addTiles()
    
    beginGame()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
  
  func beginGame() {
    shuffle()
  }

  func shuffle() {
    let newPlanets = level.shuffle()
    scene.addSprites(for: newPlanets)
  }
  
  func handleSwipe(_ swap: Swap) {
    view.isUserInteractionEnabled = false

    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animate(swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }
  
  func handleMatches() {
    let chains = level.removeMatches()
    scene.animateMatchedPlanets(for: chains) {
      self.view.isUserInteractionEnabled = true
    }
  }
}
