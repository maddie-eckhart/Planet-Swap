import SpriteKit

// MARK: - PlanetType
enum PlanetType: Int {
  case unknown = 0, blue, red, brown, green, purple, gold
  var spriteName: String {
    let spriteNames = ["blue","red","brown","green","purple","gold"]
    return spriteNames[rawValue - 1]
  }

  var highlightedSpriteName: String {
    return spriteName + "-Highlighted"
  }
  
  static func random() -> PlanetType {
    return PlanetType(rawValue: Int(arc4random_uniform(6)) + 1)!
  }
}

// MARK: - Planet
class Planet: CustomStringConvertible, Hashable {
  
  func hash(into hasher: inout Hasher) {
    //var hashValue = row * 10 + column
    var hasher = Hasher()
    hasher.combine(row * 10 + column)
    let hashValue = hasher.finalize()
  }
  
  static func == (lhs: Planet, rhs: Planet) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
    
  }
 
  var description: String {
    return "type:\(planetType) square:(\(column),\(row))"
  }
  
  var column: Int
  var row: Int
  let planetType: PlanetType
  var sprite: SKSpriteNode?
  
  init(column: Int, row: Int, planetType: PlanetType) {
    self.column = column
    self.row = row
    self.planetType = planetType
  }
}
