/// Logical representation of the game grid with many empty spaces
class SpraseGrid {
    construct new(zero) {
        _grid = {}
        _zero = zero

        _fromX = 1
        _toX = -1
    }

    static makeId(x, y) { x << 16 | y }

    has(x, y) {
        var id =  SpraseGrid.makeId(x, y)
        return _grid.containsKey(id)
    }

    /// Returns the value stored at the given grid cell.    
    [x, y] {
        var id =  SpraseGrid.makeId(x, y)
        if(_grid.containsKey(id)) {
            return _grid[id]
        } else {
            _grid[id] = _zero.type.new()
            return _grid[id]
        }
    }

    /// Assigns a given value to a given grid cell.    
    [x, y]=(v) {
        var id = SpraseGrid.makeId(x, y)
        _grid[id] = v
    }
}
