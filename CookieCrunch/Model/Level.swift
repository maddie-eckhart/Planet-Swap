import Foundation

let numColumns = 9
let numRows = 9

class Level {
  
  private var planets = Array2D<Planet>(columns: numColumns, rows: numRows)
  
  func planet(atColumn column: Int, row: Int) -> Planet? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    return planets[column, row]
  }
  
  func shuffle() -> Set<Planet> {
    return createInitialPlanets()
  }

  private func createInitialPlanets() -> Set<Planet> {
    var set: Set<Planet> = []

    // 1
    for row in 0..<numRows {
      for column in 0..<numColumns {

        // 2
        let planetType = PlanetType.random()

        // 3
        let planet = Planet(column: column, row: row, planetType: planetType)
        planets[column, row] = planet

        // 4
        set.insert(planet)
      }
    }
    return set
  }
}
