import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
  //MARK: Sound FX
  let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
  let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
  let matchSound = SKAction.playSoundFileNamed("Explosion.wav", waitForCompletion: false)
  let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
  let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
  lazy var gameOverMusic: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Sad_Trombone", withExtension: "wav") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = 1
      return player
    } catch {
      return nil
    }
  }()
  
  var level: Level!

  let tileWidth: CGFloat = 40.0
  let tileHeight: CGFloat = 40.0

  let gameLayer = SKNode()
  let planetsLayer = SKNode()
  
  //MARK: Tile backgrounds
  let tilesLayer = SKNode()
  let cropLayer = SKCropNode()
  let maskLayer = SKNode()
  private var selectionSprite = SKSpriteNode()
  
  //MARK: Gestures
  var swipeHandler: ((Swap) -> Void)?
  private var swipeFromColumn: Int?
  private var swipeFromRow: Int?
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
//    let background = SKSpriteNode(imageNamed: "Background")
//    background.size = size
//    addChild(background)
 
    drawSceneStars()
    
    gameLayer.isHidden = true
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
    let _ = SKLabelNode(fontNamed: "Futura-Bold")
  }

   func drawSceneStars() {
    let viewMidX = frame.width
    let viewMidY = frame.height
    // large stars
    for _ in 1...100 {
      let star = SKShapeNode(circleOfRadius: 3)
      let xPosition = frame.midX - viewMidX + CGFloat(arc4random_uniform(UInt32(viewMidX*2)))
      let yPosition = frame.midY - viewMidY + CGFloat(arc4random_uniform(UInt32(viewMidY*2)))
      star.position = CGPoint(x: xPosition, y: yPosition)
      star.fillColor = SKColor.white
      self.addChild(star)
    }
    // small stars
    for _ in 1...200 {
      let star = SKShapeNode(circleOfRadius: 1)
      let xPosition = frame.midX - viewMidX + CGFloat(arc4random_uniform(UInt32(viewMidX*2)))
      let yPosition = frame.midY - viewMidY + CGFloat(arc4random_uniform(UInt32(viewMidY*2)))
      star.position = CGPoint(x: xPosition, y: yPosition)
      star.glowWidth = 1.0
      star.fillColor = SKColor.white
      self.addChild(star)
    }
  }
  
  func addSprites(for planets: Set<Planet>) {
    for planet in planets {
      let sprite = SKSpriteNode(imageNamed: planet.planetType.spriteName)
      sprite.size = CGSize(width: tileWidth - 5, height: tileHeight - 5)
      sprite.position = pointFor(column: planet.column, row: planet.row)
      planetsLayer.addChild(sprite)
      planet.sprite = sprite
      // Give each cookie sprite a small, random delay. Then fade them in.
      sprite.alpha = 0
      sprite.xScale = 0.5
      sprite.yScale = 0.5

      sprite.run(
        SKAction.sequence([
          SKAction.wait(forDuration: 0.25, withRange: 0.5),
          SKAction.group([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.scale(to: 1.0, duration: 0.25)
            ])
          ]))
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
  
  func animateGameOver(_ completion: @escaping () -> Void) {
    //gameOverMusic?.play()
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeIn
    gameLayer.run(action, completion: completion)
  }

  func animateReshuffle(_ completion: @escaping () -> Void) {
//    let actionIn = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
//    actionIn.timingMode = .easeIn
//    gameLayer.run(actionIn, completion: completion)
//    let actionOut = SKAction.move(by: CGVector(dx: 0, dy: size.height), duration: 0.3)
//    actionOut.timingMode = .easeIn
//    gameLayer.run(actionOut, completion: completion)
  }
  
  func animateBeginGame(_ completion: @escaping () -> Void) {
    gameLayer.isHidden = false
    gameLayer.position = CGPoint(x: 0, y: size.height)
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeOut
    gameLayer.run(action, completion: completion)
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
  
  func animateMatchedPlanets(for chains: Set<Chain>, completion: @escaping () -> Void) {
    for chain in chains {
      animateScore(for: chain)
      for planet in chain.planets {
        if let sprite = planet.sprite {
          if sprite.action(forKey: "removing") == nil {
            let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
            scaleAction.timingMode = .easeOut
            sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                       withKey: "removing")
          }
        }
      }
    }
    run(matchSound)
    run(SKAction.wait(forDuration: 0.3), completion: completion)
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
  
  func animateFallingPlanets(in columns: [[Planet]], completion: @escaping () -> Void) {
    // 1
    var longestDuration: TimeInterval = 0
    for array in columns {
      for (index, planet) in array.enumerated() {
        let newPosition = pointFor(column: planet.column, row: planet.row)
        // 2
        let delay = 0.05 + 0.15 * TimeInterval(index)
        // 3
        let sprite = planet.sprite!   // sprite always exists at this point
        let duration = TimeInterval(((sprite.position.y - newPosition.y) / tileHeight) * 0.1)
        // 4
        longestDuration = max(longestDuration, duration + delay)
        // 5
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([moveAction, fallingCookieSound])]))
      }
    }

    // 6
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  func animateNewPlanets(in columns: [[Planet]], completion: @escaping () -> Void) {
    // 1
    var longestDuration: TimeInterval = 0

    for array in columns {
      // 2
      let startRow = array[0].row + 1

      for (index, planet) in array.enumerated() {
        // 3
        let sprite = SKSpriteNode(imageNamed: planet.planetType.spriteName)
        sprite.size = CGSize(width: tileWidth - 5, height: tileHeight - 5)
        sprite.position = pointFor(column: planet.column, row: startRow)
        planetsLayer.addChild(sprite)
        planet.sprite = sprite
        // 4
        let delay = 0.1 + 0.2 * TimeInterval(array.count - index - 1)
        // 5
        let duration = TimeInterval(startRow - planet.row) * 0.1
        longestDuration = max(longestDuration, duration + delay)
        // 6
        let newPosition = pointFor(column: planet.column, row: planet.row)
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.alpha = 0
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([
              SKAction.fadeIn(withDuration: 0.05),
              moveAction,
              addCookieSound])
            ]))
      }
    }
    // 7
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  func animateScore(for chain: Chain) {
    // Figure out what the midpoint of the chain is.
    let firstSprite = chain.firstPlanet().sprite!
    let lastSprite = chain.lastPlanet().sprite!
    let centerPosition = CGPoint(
      x: (firstSprite.position.x + lastSprite.position.x)/2,
      y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)

    // Add a label for the score that slowly floats up.
    let scoreLabel = SKLabelNode(fontNamed: "Futura-Bold")
    scoreLabel.fontSize = 16
    scoreLabel.text = String(format: "%ld", chain.score)
    scoreLabel.position = centerPosition
    scoreLabel.zPosition = 300
    planetsLayer.addChild(scoreLabel)

    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
    moveAction.timingMode = .easeOut
    scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
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
  
  func removeAllPlanetSprites() {
    planetsLayer.removeAllChildren()
  }
  
}


