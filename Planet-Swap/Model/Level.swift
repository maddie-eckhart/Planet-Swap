import Foundation

let numColumns = 9
let numRows = 9

class Level {
  
  private var planets = Array2D<Planet>(columns: numColumns, rows: numRows)
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
  private var possibleSwaps: Set<Swap> = []
  
  func planet(atColumn column: Int, row: Int) -> Planet? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    return planets[column, row]
  }
  
  func shuffle() -> Set<Planet> {
    var set: Set<Planet>
    repeat {
      set = createInitialPlanets()
      detectPossibleSwaps()
      print("possible swaps: \(possibleSwaps)")
    } while possibleSwaps.count == 0

    return set
  }

  private func createInitialPlanets() -> Set<Planet> {
    var set: Set<Planet> = []

    for row in 0..<numRows {
      for column in 0..<numColumns {
        if tiles[column, row] != nil {
          var planetType: PlanetType
          repeat {
            planetType = PlanetType.random()
          } while (column >= 2 &&
            planets[column - 1, row]?.planetType == planetType &&
            planets[column - 2, row]?.planetType == planetType) || (row >= 2 &&
              planets[column, row - 1]?.planetType == planetType &&
              planets[column, row - 2]?.planetType == planetType)

          let planet = Planet(column: column, row: row, planetType: planetType)
          planets[column, row] = planet

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
  
  private func hasChain(atColumn column: Int, row: Int) -> Bool {
    let planetType = planets[column, row]!.planetType

    // Horizontal chain check
    var horizontalLength = 1

    // Left
    var i = column - 1
    while i >= 0 && planets[i, row]?.planetType == planetType {
      i -= 1
      horizontalLength += 1
    }

    // Right
    i = column + 1
    while i < numColumns && planets[i, row]?.planetType == planetType {
      i += 1
      horizontalLength += 1
    }
    if horizontalLength >= 3 { return true }

    // Vertical chain check
    var verticalLength = 1

    // Down
    i = row - 1
    while i >= 0 && planets[column, i]?.planetType == planetType {
      i -= 1
      verticalLength += 1
    }

    // Up
    i = row + 1
    while i < numRows && planets[column, i]?.planetType == planetType {
      i += 1
      verticalLength += 1
    }
    return verticalLength >= 3
  }
  
  func detectPossibleSwaps() {
    var set: Set<Swap> = []

    for row in 0..<numRows {
      for column in 0..<numColumns {
        if let planet = planets[column, row] {
          // Have a planet in this spot? If there is no tile, there is no planet.
          if column < numColumns - 1,
            let other = planets[column + 1, row] {
            // Swap them
            planets[column, row] = other
            planets[column + 1, row] = planet

            // Is either planet now part of a chain?
            if hasChain(atColumn: column + 1, row: row) ||
              hasChain(atColumn: column, row: row) {
              set.insert(Swap(planetA: planet, planetB: other))
            }

            // Swap them back
            planets[column, row] = planet
            planets[column + 1, row] = other
          }
          if row < numRows - 1,
              let other = planets[column, row + 1] {
              planets[column, row] = other
              planets[column, row + 1] = planet
              
              // Is either planet now part of a chain?
              if hasChain(atColumn: column, row: row + 1) ||
                hasChain(atColumn: column, row: row) {
                set.insert(Swap(planetA: planet, planetB: other))
              }
              
              // Swap them back
              planets[column, row] = planet
              planets[column, row + 1] = other
            }
          }
          else if column == numColumns - 1, let planet = planets[column, row] {
            if row < numRows - 1,
              let other = planets[column, row + 1] {
              planets[column, row] = other
              planets[column, row + 1] = planet
              
              // Is either planet now part of a chain?
              if hasChain(atColumn: column, row: row + 1) ||
                hasChain(atColumn: column, row: row) {
                set.insert(Swap(planetA: planet, planetB: other))
              }
              
              // Swap them back
              planets[column, row] = planet
              planets[column, row + 1] = other
            }
        }
      }
    }

    possibleSwaps = set
  }
  
  func isPossibleSwap(_ swap: Swap) -> Bool {
    return possibleSwaps.contains(swap)
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
