struct Swap: CustomStringConvertible {
  let planetA: Planet
  let planetB: Planet
  
  init(planetA: Planet, planetB: Planet) {
    self.planetA = planetA
    self.planetB = planetB
  }
  
  var description: String {
    return "swap \(planetA) with \(planetB)"
  }
}
