import SpriteKit
import GameplayKit

class GameScene: SKScene {
  // Sound FX
  let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
  let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
  let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
  let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
  let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
  
  var level: Level!

  let tileWidth: CGFloat = 32.0
  let tileHeight: CGFloat = 36.0

  let gameLayer = SKNode()
  let planetsLayer = SKNode()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    let background = SKSpriteNode(imageNamed: "Background")
    background.size = size
    addChild(background)
    
    addChild(gameLayer)

    let layerPosition = CGPoint(
        x: -tileWidth * CGFloat(numColumns) / 2,
        y: -tileHeight * CGFloat(numRows) / 2)

    planetsLayer.position = layerPosition
    gameLayer.addChild(planetsLayer)
  }
  
  func addSprites(for planets: Set<Planet>) {
    for planet in planets {
      let sprite = SKSpriteNode(imageNamed: planet.planetType.spriteName)
      sprite.size = CGSize(width: tileWidth, height: tileHeight)
      sprite.position = pointFor(column: planet.column, row: planet.row)
      planetsLayer.addChild(sprite)
      planet.sprite = sprite
    }
  }

  private func pointFor(column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column) * tileWidth + tileWidth / 2,
      y: CGFloat(row) * tileHeight + tileHeight / 2)
  }
  
}


