// This helper file will help access grid coordinates in your code.
// If you know the column and row numbers of a specific item, you can
// index the array as follows: myCookie = cookies[column, row]
// The notation Array2D<T> means that this struct is a generic and can
// hold elements of any type T

struct Array2D<T> {
  let columns: Int
  let rows: Int
  private var array: Array<T?>
  
  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    array = Array<T?>(repeating: nil, count: rows*columns)
  }
  
  subscript(column: Int, row: Int) -> T? {
    get {
      return array[row*columns + column]
    }
    set {
      array[row*columns + column] = newValue
    }
  }
}
