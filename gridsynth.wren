import "data" for Grid, SparseGrid

class GridRule {
    /// 
    construct new(match, replace) {
        _match = match
        _replace = replace
    }

    match{ _match }
    replace{ _replace }
}

class GridTransform {
    construct new() {
        _rules = []
    }

    add(rule) {
        _rules.add(rule)
    }
}



class GridTransomer {
    construct new(input, output) {
        _input = input
        _output = output
        _rules = []
    } 
}