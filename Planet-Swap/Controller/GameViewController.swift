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
  
  var tapGestureRecognizer: UITapGestureRecognizer!
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
    gameOverPanel.isHidden = true
    
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
    movesLeft = level.maximumMoves
    score = 0
    updateLabels()
    level.resetComboMultiplier()
    shuffle()
  }

  func shuffle() {
    let newPlanets = level.shuffle()
    scene.addSprites(for: newPlanets)
  }
  
  func decrementMoves() {
    movesLeft -= 1
    updateLabels()
    if score >= level.targetScore {
      gameOverPanel.image = UIImage(named: "LevelComplete")
      showGameOver()
    } else if movesLeft == 0 {
      gameOverPanel.image = UIImage(named: "GameOver")
      showGameOver()
    }
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
    if chains.count == 0 {
      beginNextTurn()
      return
    }
    scene.animateMatchedPlanets(for: chains) {
      for chain in chains {
        self.score += chain.score
      }
      self.updateLabels()
      let columns = self.level.fillHoles()
      self.scene.animateFallingPlanets(in: columns) {
        let columns = self.level.topUpPlanets()
        self.scene.animateNewPlanets(in: columns) {
          self.handleMatches()
        }
      }
    }
  }
  
  func beginNextTurn() {
    level.detectPossibleSwaps()
    view.isUserInteractionEnabled = true
    decrementMoves()
  }
  
  func updateLabels() {
    targetLabel.text = String(format: "%ld", level.targetScore)
    movesLabel.text = String(format: "%ld", movesLeft)
    scoreLabel.text = String(format: "%ld", score)
  }
  
  func showGameOver() {
    gameOverPanel.isHidden = false
    scene.isUserInteractionEnabled = false

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideGameOver))
    self.view.addGestureRecognizer(self.tapGestureRecognizer)
  }
  
  @objc func hideGameOver() {
    view.removeGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer = nil

    gameOverPanel.isHidden = true
    scene.isUserInteractionEnabled = true

    beginGame()
  }
}
