import "random" for Random // Random is a part of the Wren library

/// Logical representation of the game grid.
class Grid {
    construct new(width, height) {
        _random = Random.new(1000)
        _grid = []
        _width = width
        _height = height

        var n = _width * _height
        for (i in 1..n) {
            _grid.add(0)
        }

        _eventListener = null
    }


    /// The number of columns in the grid.
    width { _width }

    /// The number of rows in the grid.
    height { _height }

    /// Returns the value stored at the given grid cell.
    getValue(x, y) {
        return _grid[y * _width + x]
    } 

    /// Assigns a given value to a given grid cell.
    setValue(x, y, val) {
        _grid[y*_width + x] = val
    }

    /// Checks if a given cell position exists in the grid.
    isValidPosition(x, y) {
        return x >= 0 && x < _width && y >= 0 && y < _height
    }

    /// Prints the contents of this grid to the console.
    print() {
        var line = "\n"
        for (y in 0..._height) {
            for (x in 0..._width) {
                var val = getValue(x,y)
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