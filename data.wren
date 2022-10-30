/// Logical representation of a (game) grid
class Grid {
    
    construct new(width, height, zero) {
        _grid = []
        _width = width
        _height = height
        _zero = zero

        var n = _width * _height
        for (i in 1..n) {
            _grid.add(zero)
        }
    }

    /// The number of columns in the grid.
    width { _width }

    /// The number of rows in the grid.
    height { _height }

    /// Swaps the values of two given grid cells.
    swapValues(x1, y1, x2, y2) {
        if (!valid(x1,y1) || !valid(x2,y2)) {
            return false
        }
        
        var val1 = [x1,y1]
        var val2 = [x2,y2]
        this[x1, y1] = val2
        this[x2, y2] = val1        
        return true
    }

    /// Checks if a given cell position exists in the grid.
    valid(x, y) {
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

/// Logical representation of a grid with many empty spaces
class SpraseGrid {

    construct new() {
        _grid = {}
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

    clear() {
        _grid.clear()
    }
}

/// First-in-first-out (FIFO) data structure 
class Queue {

    construct new() {
        _data = []
    }

    push(val) {
        _data.add(val)
    }

    pop() {
        if(!empty()) {
            var val = _data[0]
            _data.removeAt(0)
            return val
        }
    }

    empty() { _data.count == 0 }
 }

/// Last-in-fist-out (LIFO data structure)
class Dequeue {

    construct new() {
        _data = []
    }

    push(val) {
        _data.add(val)
    }

    pop() {
        if(!empty()) {
            var val = _data[_data.count - 1]
            _data.removeAt(_data.count - 1)
            return val
        }
    }

    empty() { _data.count == 0 }
 }

 