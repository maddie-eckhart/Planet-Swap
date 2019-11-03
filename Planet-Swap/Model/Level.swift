import Foundation

let numColumns = 9
let numRows = 9

class Level {
  
  private var planets = Array2D<Planet>(columns: numColumns, rows: numRows)
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
  
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
        if tiles[column, row] != nil {
          // 2
          let planetType = PlanetType.random()

          // 3
          let planet = Planet(column: column, row: row, planetType: planetType)
          planets[column, row] = planet

          // 4
          set.insert(planet)
        }
      }
    }
    return set
  }

  func tileAt(column: Int, row: Int) -> Tile? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    return tiles[column, row]
  }
  
  init(filename: String) {
    // 1
    guard let levelData = LevelData.loadFrom(file: filename) else { return }
    // 2
    let tilesArray = levelData.tiles
    // 3
    for (row, rowArray) in tilesArray.enumerated() {
      // 4
      let tileRow = numRows - row - 1
      // 5
      for (column, value) in rowArray.enumerated() {
        if value == 1 {
          tiles[column, tileRow] = Tile()
        }
      }
    }
  }
  
  func performSwap(_ swap: Swap) {
    let columnA = swap.planetA.column
    let rowA = swap.planetA.row
    let columnB = swap.planetB.column
    let rowB = swap.planetB.row

    planets[columnA, rowA] = swap.planetB
    swap.planetB.column = columnA
    swap.planetB.row = rowA

    planets[columnB, rowB] = swap.planetA
    swap.planetA.column = columnB
    swap.planetA.row = rowB
  }
}
