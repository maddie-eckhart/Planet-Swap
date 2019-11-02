import SpriteKit

// MARK: - PlanetType
enum PlanetType: Int {
  case unknown = 0, croissant, cupcake, danish, donut, macaroon, sugarCookie
}

// MARK: - Planet
class Planet: CustomStringConvertible, Hashable {
  
  var hashValue: Int {
    return row * 10 + column
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
