/// Logical representation of the game grid.
class SpraseGrid {
    construct new(zero) {
        _grid = {}
        _zero = zero

        _fromX = 1
        _toX = -1
    }

    static makeId(x, y) { x << 16 | y }

    /// Checks if a given cell position exists in the grid.
    isValidPosition(x, y) {
        return true
    }    

    /// Returns the value stored at the given grid cell.    
    [x, y] {
        var id =  SpraseGrid.makeId(x, y)
        var val = _grid[id]
        if(val != null) {
            return val
        }
        return _zero
    }

    /// Assigns a given value to a given grid cell.    
    [x, y]=(v) {
        var id = SpraseGrid.makeId(x, y)
        _grid[id] = v
    }
}
