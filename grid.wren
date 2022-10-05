/// Logical representation of the game grid.
class Grid {
    construct new(width, height, val) {
        _grid = []
        _width = width
        _height = height

        var n = _width * _height
        for (i in 1..n) {
            _grid.add(val)
        }
    }

    /// The number of columns in the grid.
    width { _width }

    /// The number of rows in the grid.
    height { _height }

    /// Swaps the values of two given grid cells.
    swapValues(x1, y1, x2, y2) {
        if (!isValidPosition(x1,y1) || !isValidPosition(x2,y2)) {
            return false
        }
        
        var val1 = [x1,y1]
        var val2 = [x2,y2]
        this[x1, y1] = val2
        this[x2, y2] = val1        
        return true
    }

    /// Checks if a given cell position exists in the grid.
    isValidPosition(x, y) {
        return x >= 0 && x < _width && y >= 0 && y < _height
    }    

    /// Returns the value stored at the given grid cell.    
    [x, y] {
        return _grid[y * _width + x]
    }

    /// Assigns a given value to a given grid cell.    
    [x, y]=(v) {
        _grid[y * _width + x] = v
    }    

    /// Prints the contents of this grid to the console.
    print() {
        var line = "\n"
        for (y in (_height-1)..0) {
            for (x in 0..._width) {
                var val = this[x,y]
                if (val == 0) {
                    line = line + " ."
                } else {
                    line = line + " %(val)"
                }
            }
            line = line + "\n"
        }
        System.print(line)
    }    
}