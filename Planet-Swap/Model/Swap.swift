struct Swap: CustomStringConvertible, Hashable {
  let planetA: Planet
  let planetB: Planet
  
  init(planetA: Planet, planetB: Planet) {
    self.planetA = planetA
    self.planetB = planetB
  }
  
  var description: String {
    return "swap \(planetA) with \(planetB)"
  }
  
  var hashValue: Int {
    return planetA.hashValue ^ planetB.hashValue
  }

  static func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.planetA == rhs.planetA && lhs.planetB == rhs.planetB) ||
      (lhs.planetB == rhs.planetA && lhs.planetA == rhs.planetB)
  }
}
