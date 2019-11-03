class Chain: Hashable, CustomStringConvertible {
  var planets: [Planet] = []

  enum ChainType: CustomStringConvertible {
    case horizontal
    case vertical

    var description: String {
      switch self {
      case .horizontal: return "Horizontal"
      case .vertical: return "Vertical"
      }
    }
  }

  var chainType: ChainType

  init(chainType: ChainType) {
    self.chainType = chainType
  }

  func add(planet: Planet) {
    planets.append(planet)
  }

  func firstPlanet() -> Planet {
    return planets[0]
  }

  func lastPlanet() -> Planet {
    return planets[planets.count - 1]
  }

  var length: Int {
    return planets.count
  }

  var description: String {
    return "type:\(chainType) planets:\(planets)"
  }

  var hashValue: Int {
    return planets.reduce (0) { $0.hashValue ^ $1.hashValue }
  }

  static func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.planets == rhs.planets
  }
}
