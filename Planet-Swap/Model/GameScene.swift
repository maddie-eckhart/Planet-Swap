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

  let tileWidth: CGFloat = 40.0
  let tileHeight: CGFloat = 40.0

  let gameLayer = SKNode()
  let planetsLayer = SKNode()
  
  // Tile backgrounds
  let tilesLayer = SKNode()
  let cropLayer = SKCropNode()
  let maskLayer = SKNode()
  private var selectionSprite = SKSpriteNode()
  
  // Gestures
  var swipeHandler: ((Swap) -> Void)?
  private var swipeFromColumn: Int?
  private var swipeFromRow: Int?
  
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
    
    tilesLayer.position = layerPosition
    maskLayer.position = layerPosition
    cropLayer.maskNode = maskLayer
    gameLayer.addChild(tilesLayer)
    gameLayer.addChild(cropLayer)
    
    planetsLayer.position = layerPosition
    cropLayer.addChild(planetsLayer)
  }
  
  func addSprites(for planets: Set<Planet>) {
    for planet in planets {
      let sprite = SKSpriteNode(imageNamed: planet.planetType.spriteName)
      sprite.size = CGSize(width: tileWidth - 5, height: tileHeight - 5)
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
  
  private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth &&
      point.y >= 0 && point.y < CGFloat(numRows) * tileHeight {
      return (true, Int(point.x / tileWidth), Int(point.y / tileHeight))
    } else {
      return (false, 0, 0)  // invalid location
    }
  }
  
  func addTiles() {
    // 1
    for row in 0..<numRows {
      for column in 0..<numColumns {
        if level.tileAt(column: column, row: row) != nil {
          let tileNode = SKSpriteNode(imageNamed: "MaskTile")
          tileNode.size = CGSize(width: tileWidth, height: tileHeight)
          tileNode.position = pointFor(column: column, row: row)
          maskLayer.addChild(tileNode)
        }
      }
    }

    // 2
    for row in 0...numRows {
      for column in 0...numColumns {
        let topLeft     = (column > 0) && (row < numRows)
          && level.tileAt(column: column - 1, row: row) != nil
        let bottomLeft  = (column > 0) && (row > 0)
          && level.tileAt(column: column - 1, row: row - 1) != nil
        let topRight    = (column < numColumns) && (row < numRows)
          && level.tileAt(column: column, row: row) != nil
        let bottomRight = (column < numColumns) && (row > 0)
          && level.tileAt(column: column, row: row - 1) != nil

        var value = (topLeft ? 1 : 0)
        value = value | (topRight ? 1 : 0) << 1
        value = value | (bottomLeft ? 1 : 0) << 2
        value = value | (bottomRight ? 1 : 0) << 3

        // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
        if value != 0 && value != 6 && value != 9 {
          let name = String(format: "Tile_%ld", value)
          let tileNode = SKSpriteNode(imageNamed: name)
          tileNode.size = CGSize(width: tileWidth, height: tileHeight)
          var point = pointFor(column: column, row: row)
          point.x -= tileWidth / 2
          point.y -= tileHeight / 2
          tileNode.position = point
          tilesLayer.addChild(tileNode)
        }
      }
    }
  }
  
  func showSelectionIndicator(of planet: Planet) {
    if selectionSprite.parent != nil {
      selectionSprite.removeFromParent()
    }

    if let sprite = planet.sprite {
      let texture = SKTexture(imageNamed: planet.planetType.highlightedSpriteName)
      selectionSprite.size = CGSize(width: tileWidth, height: tileHeight)
      selectionSprite.run(SKAction.setTexture(texture))

      sprite.addChild(selectionSprite)
      selectionSprite.alpha = 1.0
    }
  }
  
  func hideSelectionIndicator() {
    selectionSprite.run(SKAction.sequence([
      SKAction.fadeOut(withDuration: 0.3),
      SKAction.removeFromParent()]))
  }
  
  // Gestures
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: planetsLayer)
    let (success, column, row) = convertPoint(location)
    if success {
      if let planet = level.planet(atColumn: column, row: row) {
        showSelectionIndicator(of: planet)
        swipeFromColumn = column
        swipeFromRow = row
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    guard swipeFromColumn != nil else { return }

    guard let touch = touches.first else { return }
    let location = touch.location(in: planetsLayer)

    let (success, column, row) = convertPoint(location)
    if success {

      var horizontalDelta = 0, verticalDelta = 0
      if column < swipeFromColumn! {          // swipe left
        horizontalDelta = -1
      } else if column > swipeFromColumn! {   // swipe right
        horizontalDelta = 1
      } else if row < swipeFromRow! {         // swipe down
        verticalDelta = -1
      } else if row > swipeFromRow! {         // swipe up
        verticalDelta = 1
      }

      if horizontalDelta != 0 || verticalDelta != 0 {
        trySwap(horizontalDelta: horizontalDelta, verticalDelta: verticalDelta)
        hideSelectionIndicator()
        swipeFromColumn = nil
      }
    }
  }
  
  private func trySwap(horizontalDelta: Int, verticalDelta: Int) {
    // 1
    let toColumn = swipeFromColumn! + horizontalDelta
    let toRow = swipeFromRow! + verticalDelta
    // 2
    guard toColumn >= 0 && toColumn < numColumns else { return }
    guard toRow >= 0 && toRow < numRows else { return }
    // 3
    if let toPlanet = level.planet(atColumn: toColumn, row: toRow),
      let fromPlanet = level.planet(atColumn: swipeFromColumn!, row: swipeFromRow!) {
      // 4
      if let handler = swipeHandler {
        let swap = Swap(planetA: fromPlanet, planetB: toPlanet)
        handler(swap)
      }
    }
  }
  
  func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> Void) {
    let spriteA = swap.planetA.sprite!
    let spriteB = swap.planetB.sprite!

    spriteA.zPosition = 100
    spriteB.zPosition = 90

    let duration: TimeInterval = 0.2

    let moveA = SKAction.move(to: spriteB.position, duration: duration)
    moveA.timingMode = .easeOut

    let moveB = SKAction.move(to: spriteA.position, duration: duration)
    moveB.timingMode = .easeOut

    spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
    spriteB.run(SKAction.sequence([moveB, moveA]))

    run(invalidSwapSound)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if selectionSprite.parent != nil && swipeFromColumn != nil {
      hideSelectionIndicator()
    }
    swipeFromColumn = nil
    swipeFromRow = nil
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }
  
  func animate(_ swap: Swap, completion: @escaping () -> Void) {
    let spriteA = swap.planetA.sprite!
    let spriteB = swap.planetB.sprite!

    spriteA.zPosition = 100
    spriteB.zPosition = 90

    let duration: TimeInterval = 0.3

    let moveA = SKAction.move(to: spriteB.position, duration: duration)
    moveA.timingMode = .easeOut
    spriteA.run(moveA, completion: completion)

    let moveB = SKAction.move(to: spriteA.position, duration: duration)
    moveB.timingMode = .easeOut
    spriteB.run(moveB)

    run(swapSound)
  }
  
}


