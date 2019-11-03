import Foundation

let numColumns = 9
let numRows = 9
let numLevels = 4

class Level {
  
  private var planets = Array2D<Planet>(columns: numColumns, rows: numRows)
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
  private var possibleSwaps: Set<Swap> = []
  
  var targetScore = 0
  var maximumMoves = 0
  private var comboMultiplier = 0
  
  private func calculateScores(for chains: Set<Chain>) {
    // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
    for chain in chains {
      chain.score = 60 * (chain.length - 2) * comboMultiplier
      comboMultiplier += 1
    }
  }
  
  func resetComboMultiplier() {
    comboMultiplier = 1
  }
  
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
    guard let levelData = LevelData.loadFrom(file: filename) else { return }
    let tilesArray = levelData.tiles

    for (row, rowArray) in tilesArray.enumerated() {
      let tileRow = numRows - row - 1
      for (column, value) in rowArray.enumerated() {
        if value == 1 {
          tiles[column, tileRow] = Tile()
        }
      }
    }
    targetScore = levelData.targetScore
    maximumMoves = levelData.moves
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
  
  private func detectHorizontalMatches() -> Set<Chain> {
    // 1
    var set: Set<Chain> = []
    // 2
    for row in 0..<numRows {
      var column = 0
      while column < numColumns-2 {
        // 3
        if let planet = planets[column, row] {
          let matchType = planet.planetType
          // 4
          if planets[column + 1, row]?.planetType == matchType &&
            planets[column + 2, row]?.planetType == matchType {
            // 5
            let chain = Chain(chainType: .horizontal)
            repeat {
              chain.add(planet: planets[column, row]!)
              column += 1
            } while column < numColumns && planets[column, row]?.planetType == matchType

            set.insert(chain)
            continue
          }
        }
        // 6
        column += 1
      }
    }
    return set
  }
  
  private func detectVerticalMatches() -> Set<Chain> {
    var set: Set<Chain> = []

    for column in 0..<numColumns {
      var row = 0
      while row < numRows-2 {
        if let planet = planets[column, row] {
          let matchType = planet.planetType

          if planets[column, row + 1]?.planetType == matchType &&
            planets[column, row + 2]?.planetType == matchType {
            let chain = Chain(chainType: .vertical)
            repeat {
              chain.add(planet: planets[column, row]!)
              row += 1
            } while row < numRows && planets[column, row]?.planetType == matchType

            set.insert(chain)
            continue
          }
        }
        row += 1
      }
    }
    return set
  }
  
  func removeMatches() -> Set<Chain> {
    let horizontalChains = detectHorizontalMatches()
    let verticalChains = detectVerticalMatches()

    removePlanets(in: horizontalChains)
    removePlanets(in: verticalChains)

    calculateScores(for: horizontalChains)
    calculateScores(for: verticalChains)
    return horizontalChains.union(verticalChains)
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
  
  private func removePlanets(in chains: Set<Chain>) {
    for chain in chains {
      for planet in chain.planets {
        planets[planet.column, planet.row] = nil
      }
    }
  }
  
  func fillHoles() -> [[Planet]] {
      var columns: [[Planet]] = []
      // 1
      for column in 0..<numColumns {
        var array: [Planet] = []
        for row in 0..<numRows {
          // 2
          if tiles[column, row] != nil && planets[column, row] == nil {
            // 3
            for lookup in (row + 1)..<numRows {
              if let planet = planets[column, lookup] {
                // 4
                planets[column, lookup] = nil
                planets[column, row] = planet
                planet.row = row
                // 5
                array.append(planet)
                // 6
                break
              }
            }
          }
        }
        // 7
        if !array.isEmpty {
          columns.append(array)
        }
      }
      return columns
  }
  
  func topUpPlanets() -> [[Planet]] {
    var columns: [[Planet]] = []
    var planetType: PlanetType = .unknown

    for column in 0..<numColumns {
      var array: [Planet] = []

      // 1
      var row = numRows - 1
      while row >= 0 && planets[column, row] == nil {
        // 2
        if tiles[column, row] != nil {
          // 3
          var newPlanetType: PlanetType
          repeat {
            newPlanetType = PlanetType.random()
          } while newPlanetType == planetType
          planetType = newPlanetType
          // 4
          let planet = Planet(column: column, row: row, planetType: planetType)
          planets[column, row] = planet
          array.append(planet)
        }

        row -= 1
      }
      // 5
      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }
}
