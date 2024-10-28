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
    
    /// Creates a unique identifier for a given cell position.
    static makeId(x, y) { x << 16 | y }  

    /// Checks if a given cell position exists in the grid.
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

    /// Clears the grid.
    clear() {
        _grid.clear()
    }

    /// Returns the values stored in the grid.
    values { _grid.values }
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

 class Rule {
    /// Creates a new rule with the given match and replace sparse grids (patterns).
    /// The sparse grid define values for coordinates from 1 to -1 on both x and y axis
    /// efefctively defining a 3x3 grid.s
    /// The probablity of the rule being applied is 1.0 and the priority is 0.
    construct new(match, replace) {
        _match = match
        _replace = replace
        _probablity = 1.0
        _priority = 0
    }

    probablity=(p) { _probablity = p }
    probablity { _probablity }

    priority=(p) { _priority = p }
    priority { _priority }

    match { _match }
    replace { _replace }
 }

 class GridProcessor {

    /// Creates a new grid processor with the given input and output grids.
    construct new(input, output) {
        _input = input
        _output = output
        _rules = []
    }

    /// Adds a rule to the grid processor.
    addRule(rule) {
        _rules.add(rule)
    }

    process() {
        var width = _input.width
        var height = _input.height
        for(y in 0...height) {
            for(x in 0...width) {

                for(j in 1..-1) {
                    for(i in 1..-1) {
                        match[i,j] == _input[x+i, y+j]
                    }
                }
                for(rule in _rules) {
                    if(match == rule.match) {
                        for(j in 1..-1) {
                            for(i in 1..-1) {
                                _output[x+i, y+j] = rule.replace[i,j]
                            }
                        }
                    }
                }
            }
        }

    }
 }

 